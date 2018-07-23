# frozen_string_literal: true

module CaseCore
  need 'helpers/log'
  need 'tasks/transfer/extractors/request_attributes'
  need 'tasks/transfer/extractors/requests'

  module Tasks
    class Transfer
      module Importers
        # Класс объектов, импортирующих записи межведомственных запросов
        class Requests
          include CaseCore::Helpers::Log

          # Импортирует записи межведомственных запросов
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def self.import(hub)
            new(hub).import
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def initialize(hub)
            @hub = hub
          end

          # Список полей записей атрибутов межведомственных запросов
          ATTR_COLUMNS = %i[request_id name value]

          # Импортирует записи межведомственных запросов
          def import
            requests = Extractors::Requests.extract(hub)
            requests = requests.each_with_object({}) do |request, memo|
              params = request.slice(:case_id, :created_at)
              record = Models::Request.create(params)
              memo[record.id] = request
            end
            log_imported_requests(requests.size, binding)
            attr_values = request_attr_values(requests)
            Models::RequestAttribute.import(ATTR_COLUMNS, attr_values)
            log_imported_request_attrs(attr_values.size, binding)
          end

          private

          # Объект, предоставляющий доступ к данным
          # @return [CaseCore::Tasks::Transfer::DataHub]
          #   объект, предоставляющий доступ к данным
          attr_reader :hub

          # Возвращает ассоциативный массив, в котором идентификаторам записей
          # заявок соответствует их тип
          # @return [Hash]
          #   результирующий ассоциативный массив
          def types
            @types ||= Models::Case.select(:id, :type).as_hash(:id, :type)
          end

          # Возвращает список списков значений полей записей атрибутов
          # межведомственных запросов
          # @param [Hash] requests
          #   ассоциативный массив, в котором идентификаторам импортированных
          #   записей межведомственных запросов сопоставляются ассоциативные
          #   массивы с информацией об этих запросах
          # @return [Array]
          #   результирующий список
          def request_attr_values(requests)
            requests.each_with_object([]) do |(request_id, request), memo|
              attrs = Extractors::RequestAttributes.extract(request, types)
              attrs.each { |name, value| memo << [request_id, name, value] }
            end
          end

          # Создаёт запись в журнале событий о том, что импортированы записи
          # межведомственных запросов
          # @param [Integer] count
          #   количество импортированных записей межведомственных запросов
          # @param [Binding] context
          #   контекст
          def log_imported_requests(count, context)
            log_info(context) { <<-MESSAGE }
              Импортированы записи межведомственных запросов в количестве
              #{count}
            MESSAGE
          end

          # Создаёт запись в журнале событий о том, что импортированы атрибуты
          # межведомственных запросов
          # @param [Integer] count
          #   количество импортированных атрибутов межведомственных запросов
          # @param [Binding] context
          #   контекст
          def log_imported_request_attrs(count, context)
            log_info(context) { <<-MESSAGE }
              Импортированы атрибуты межведомственных запросов в количестве
              #{count}
            MESSAGE
          end
        end
      end
    end
  end
end
