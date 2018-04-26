# frozen_string_literal: true

require_relative 'base/db'

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `case_manager`
        class CaseManager < Base::DB
          # Список ассоциативных массивов с информацией о заявках
          # @return [Array<Hash>]
          #   список ассоциативных массивов с информацией о заявках
          attr_reader :cases

          # Список ассоциативных массивов с информацией о документах
          # @return [Array<Hash>]
          #   список ассоциативных массивов с информацией о документах
          attr_reader :documents

          # Ассоциативный массив, в котором идентификаторам записей реестров
          # передаваемой корреспонденции соответствуют ассоциативные массивы с
          # информацией об этих реестрах
          # @return [Hash]
          #   ассоциативный массив с информацией о реестрах передаваемой
          #   корреспонденции
          attr_reader :registers

          # Инициализирует объект класса
          def initialize
            settings = DataHub.settings
            host = settings.cm_host
            name = settings.cm_name
            user = settings.cm_user
            pass = settings.cm_pass
            super(:postgres, host, name, user, pass)
            initialize_collections
          end

          private

          # Инициализирует коллекции данных
          def initialize_collections
            initialize_cases
            initialize_registers
            initialize_documents
          end

          # Ассоциативный массив, в котором состояниям заявок сопоставляются их
          # статусы
          CASE_STATUSES = {
            'error'      => 'Ошибка',
            'packaging'  => 'Формирование пакета документов',
            'pending'    => 'Ожидание отправки в ведомство',
            'processing' => 'Обработка пакета документов в ведомстве',
            'issuance'   => 'Выдача результата оказания услуги',
            'rejecting'  => 'Возврат невостребованного результата в ведомство',
            'closed'     => 'Закрыта'
          }.freeze

          # Ассоциативный массив, в котором состояниям заявок сопоставляются
          # названия атрибутов завершения этапа жизненного цикла заявки
          PLANNED_FINISH_DATE_ATTR_NAMES = {
            'packaging' =>  :docs_send_expected_at,
            'pending'   =>  :docs_send_expected_at,
            'processing' => :response_expected_at
          }.freeze

          # Инициализирует коллекцию данных заявок
          def initialize_cases
            @cases = db[:cases].to_a.each do |c4s3|
              c4s3[:case_id] = c4s3[:id]
              state = c4s3[:state]
              case_status = CASE_STATUSES[state]
              c4s3[:case_status] = case_status unless case_status.nil?
              prop = PLANNED_FINISH_DATE_ATTR_NAMES[state]
              c4s3[:planned_finish_date] = c4s3[prop] unless prop.nil?
            end
          end

          # Инициализирует коллекцию данных реестров передаваемой
          # корреспонденции
          def initialize_registers
            @registers = db[:registers].as_hash(:id)
          end

          # Инициализирует коллекцию данных документов заявок
          def initialize_documents
            @documents = db[:documents].to_a
          end
        end
      end
    end
  end
end
