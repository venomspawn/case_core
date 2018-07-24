# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        class Cabinet
          # Класс, предоставляющий функцию для извлечения информации о
          # доверенностях
          class VicariousAuthorities
            # Возвращает ассоциативный массив, в котором спискам из
            # идентификаторов записей заявителя и представителя соответствует
            # ассоциативный массив с информацией о последней доверенности
            # @param [Sequel::Database] database
            #   объект, предоставляющий доступ к базе данных `cabinet`
            # @param [Hash] people
            #   ассоциативный массив, в котором идентификаторам записей
            #   заявителей сопоставлены ассоциативные массивы с информацией о
            #   заявителях
            # @param [Hash] documents
            #   ассоциативный массив, в котором идентификаторам папок
            #   заявителей сопоставлены списки ассоциативных массивов с
            #   информацией о документах
            # @return [Hash]
            #   ассоциативный массив с информацией о доверенностях
            def self.data(database, people, documents)
              new(database, people, documents).data
            end

            # Инициализирует объект класса
            # @param [Sequel::Database] database
            #   объект, предоставляющий доступ к базе данных `cabinet`
            # @param [Hash] people
            #   ассоциативный массив, в котором идентификаторам записей
            #   заявителей сопоставлены ассоциативные массивы с информацией о
            #   заявителях
            # @param [Hash] documents
            #   ассоциативный массив, в котором идентификаторам папок
            #   заявителей сопоставлены списки ассоциативных массивов с
            #   информацией о документах
            def initialize(database, people, documents)
              @database  = database
              @people    = people
              @documents = documents
            end

            # Возвращает ассоциативный массив, в котором спискам из
            # идентификаторов записей заявителя и представителя соответствует
            # ассоциативный массив с информацией о последней доверенности
            # @return [Hash]
            #   ассоциативный массив с информацией о доверенностях
            def data
              dataset.each_with_object({}, &method(:process_link))
            end

            private

            # Объект, предоставляющий доступ к базе данных `cabinet`
            # @return [Sequel::Database]
            #   объект, предоставляющий доступ к базе данных `cabinet`
            attr_reader :database

            # Ассоциативный массив, в котором идентификаторам записей
            # заявителей сопоставлены ассоциативные массивы с информацией о
            # заявителях
            # @return [Hash]
            #   ассоциативный массив с информацией о заявителях
            attr_reader :people

            # Ассоциативный массив, в котором идентификаторам папок заявителей
            # сопоставлены списки ассоциативных массивов с информацией о
            # документах
            # @return [Hash]
            #   ассоциативный массив с информацией о документах
            attr_reader :documents

            # Возвращает запрос Sequel на получение записей связей между
            # заявителями и представителями
            # @return [Sequel::Dataset]
            #   результирующий запрос Sequel
            def dataset
              database[:ecm_person_spokesmen]
            end

            # Обрабатывает связь между заявителем и представителем и добавляет
            # информацию о доверенности
            # @param [Hash] link
            #   ассоциативный массив с информацией о связи
            # @param [Hash] memo
            #   ассоциативный массив с информацией о доверенностях
            def process_link(link, memo)
              person_id = link[:person_id]
              spokesman_id = link[:spokesman_id]
              doc_id = link[:power_of_attorney_id]
              process_documents(person_id, spokesman_id, doc_id, memo)
            end

            # Возвращает список ассоциативных массивов с документами заявителя.
            # Если информацию о документах заявителя невозможно найти,
            # возвращает пустой список.
            # @return [Array]
            #   результирующий список
            def person_documents(person_id)
              person = people[person_id] || {}
              folder_id = person[:private_folder_id]
              documents[folder_id] || []
            end

            # Проверяет документы заявителя и добавляет информацию о
            # доверенности
            # @param [String] person_id
            #   идентификатор записи заявителя
            # @param [String] spokesman_id
            #   идентификатор записи представителя
            # @param [String] doc_id
            #   идентификтаор записи доверенности
            # @param [Hash] memo
            #   ассоциативный массив с информацией о доверенностях
            def process_documents(person_id, spokesman_id, doc_id, memo)
              person_documents(person_id).each do |doc|
                next unless doc[:id] == doc_id
                key = [person_id, spokesman_id]
                current = memo[key]
                created_at = doc[:created_at]
                next unless current.nil? || current[:created_at] < created_at
                memo[key] = doc
              end
            end
          end
        end
      end
    end
  end
end
