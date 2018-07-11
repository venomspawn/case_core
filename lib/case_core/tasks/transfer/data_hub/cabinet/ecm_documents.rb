# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        class Cabinet
          # Класс, предоставляющий функцию для извлечения информации о
          # документах заявителей
          class ECMDocuments
            # Возвращает ассоциативный массив, в котором идентификаторам папок
            # заявителей сопоставлены списки ассоциативных массивов с
            # информацией о документах заявителей
            # @param [Sequel::Database] database
            #   объект, предоставляющий доступ к базе данных `cabinet`
            # @return [Hash]
            #   результирующий ассоциативный массив
            def self.data(database)
              new(database).data
            end

            # Инициализирует объект класса
            # @param [Sequel::Database] database
            #   объект, предоставляющий доступ к базе данных `cabinet`
            def initialize(database)
              @database = database
            end

            # Возвращает ассоциативный массив, в котором идентификаторам папок
            # заявителей сопоставлены списки ассоциативных массивов с
            # информацией о документах заявителей
            # @return [Hash]
            #   результирующий ассоциативный массив
            def data
              dataset.each_with_object({}) do |document, memo|
                document[:content] = unpack_content(document)
                folder_id = document[:folder_id]
                memo[folder_id] ||= []
                memo[folder_id] << document
              end
            end

            private

            # Объект, предоставляющий доступ к базе данных `cabinet`
            # @return [Sequel::Database]
            #   объект, предоставляющий доступ к базе данных `cabinet`
            attr_reader :database

            # Список названий столбцов, извлекаемых из таблицы `ecm_documents`
            ECM_DOCUMENTS_COLUMNS = %i[
              id
              content
              created_at
              folder_id
              schema_urn
            ].freeze

            # Возвращает запрос Sequel на получение записей документов
            # @return [Sequel::Dataset]
            #   результирующий запрос Sequel
            def dataset
              database[:ecm_documents]
                .where(folder_id: folder_ids_dataset)
                .select(*ECM_DOCUMENTS_COLUMNS)
            end

            # Возвращает запрос Sequel на получение набора идентификаторов
            # папок заявителей
            # @return [Sequel::Dataset]
            #   результирующий запрос Sequel
            def folder_ids_dataset
              database[:ecm_people].select(:private_folder_id)
            end

            # Возвращает ассоциативный массив, восстановлённый из содержимого
            # документа в ECM-формате
            # @param [Hash] document
            #   ассоциативный массив с информацией о документе
            # @return [Hash]
            #   результирующий ассоциативный массив
            def unpack_content(document)
              content = Oj.load(document[:content])
              content = [content] if content.is_a?(Hash)
              content = unpack(content)
              content = content.each_value.first
              mend_type(content)
            rescue StandardError
              {}
            end

            # Возвращает объект, восстанавливая его из ECM-формата
            # @param [Object] content
            #   исходный объект
            # @return [Object]
            #   объект, восстановлённый из ECM-формата
            def unpack(content)
              return content unless content.is_a?(Array)
              content.each_with_object({}) do |e, memo|
                return content unless e.is_a?(Hash) && e.key?('content')
                name = e['name']
                return content unless name.is_a?(String)
                memo[name] = unpack(e['content'])
              end
            end

            # Ассоциативный массив типов документов, удостоверяющих личность
            TYPES = {
              'passport_rf' =>
                'Паспорт гражданина РФ',
              'international_passport' =>
                'Загранпаспорт',
              'seaman_passport' =>
                'Паспорт моряка',
              'officer_identity_document' =>
                'Удостоверение личности военнослужащего',
              'soldier_identity_document' =>
                'Военный билет',
              'temporary_identity_card' =>
                'Временное удостоверение личности',
              'birth_certificate' =>
                'Свидетельство о рождении',
              'foreign_citizen_passport' =>
                'Паспорт иностранного гражданина',
              'residence' =>
                'Вид на жительство',
              'temporary_residence' =>
                'Разрешение на временное проживание',
              'refugee_certificate' =>
                'Удостоверение беженца',
              'certificate_of_temporary_asylum_rf' =>
                'Свидетельство о предоставлении временного убежища на '\
                'территории РФ'
            }.freeze

            # Исправляет поле `type` предоставленного ассоциативного массива,
            # если оно присутствует, и возвращает этот ассоциативный массив
            # @param [Hash] hash
            #   ассоциативный массив
            # @return [Hash] hash
            #   исправленный ассоциативный массив
            def mend_type(hash)
              hash.tap do
                type = hash['type']
                hash['type'] = TYPES[type] || type unless type.nil?
              end
            end
          end
        end
      end
    end
  end
end
