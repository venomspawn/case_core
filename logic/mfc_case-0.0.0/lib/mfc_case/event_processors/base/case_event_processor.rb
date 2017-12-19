# encoding: utf-8

module MFCCase
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён классов обработчиков событий
  #
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён базовых классов обработчиков событий
    #
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Базовый класс обработчиков событий, связанных с записью заявки
      #
      class CaseEventProcessor
        include Helpers

        # Инициализирует объект класса
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @param [NilClass, Hash] params
        #   ассоциативный массив параметров обработчика события или `nil`, если
        #   обработчик не нуждается в параметрах
        #
        # @raise [ArgumentError]
        #   если аргумент `c4s3` не является объектом класса
        #   `CaseCore::Models::Case`
        #
        # @raise [ArgumentError]
        #   если аргумент `params` не является объектом класса `NilClass` или
        #   класса `Hash`
        #
        def initialize(c4s3, params = nil)
          check_case!(c4s3)
          check_params!(params)
          @c4s3 = c4s3
          @params = params || {}
        end

        private

        # Запись заявки
        #
        # @return [CaseCore::Models::Case]
        #   запись заявки
        #
        attr_reader :c4s3

        # Ассоциативный массив параметров обработчика события
        #
        # @return [Hash]
        #   ассоциативный массив параметров обработчика события
        #
        attr_reader :params

        # Возвращает идентификатор оператора из параметров `operator_id` и
        # `exporter_id`
        #
        # @return [Object]
        #   результирующий идентификатор оператора
        #
        def person_id
          params[:operator_id] || params[:exporter_id]
        end

        # Возвращает объект с информацией о текущих дате и времени
        #
        # @return [Time]
        #   объект с информацией о текущих дате и времени
        #
        def now
          Time.now
        end

        # Сбрасывает информацию об атрибутах заявки
        #
        def reload
          @case_attributes = nil
          @case_status = nil
        end

        # Возвращает статус заявки
        #
        # @return [String]
        #   статус заявки
        #
        # @raise [RuntimeError]
        #   если статус заявки не равен одному из значений, определённых
        #   константой {STATUSES}
        #
        def case_status
          @case_status ||= extract_case_status
        end

        # Извлекает статус заявки из атрибута `status`, проверяет, является ли
        # он допустимым, и возвращает его
        #
        # @return [String]
        #   статус заявки
        #
        # @raise [RuntimeError]
        #   если статус заявки не равен одному из значений, определённых
        #   константой {STATUSES}
        #
        def extract_case_status
          status_attribute =
            case_attributes_dataset.where(name: 'status').select(:value).first
          status = status_attribute[:value]
          status.tap { check_status!(status, c4s3) }
        end

        # Возвращает ассоциативный массив атрибутов заявки
        #
        # @return [Hash]
        #   ассоциативный массив атрибутов заявки
        #
        def case_attributes
          @case_attributes ||= extract_case_attributes
        end

        # Извлекает атрибуты заявки из соответствующих записей и возвращает
        # ассоциативный массив атрибутов заявки
        #
        # @return [Hash{Symbol => Object}]
        #   результирующий ассоциативный массив
        #
        # @raise [RuntimeError]
        #   если значение атрибута `status` не равно ни одному из значений,
        #   определённых константой {STATUSES}
        #
        def extract_case_attributes
          case_attributes_dataset.select_hash(:name, :value).tap do |result|
            result.symbolize_keys!
            check_status!(result[:status], c4s3)
          end
        end

        # Возвращает запрос Sequel на получение записей атрибутов заявки
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def case_attributes_dataset
          c4s3.attributes_dataset.naked
        end

        # Обновляет атрибуты заявки
        #
        # @param [Hash] attributes
        #   ассоциативный массив атрибутов
        #
        def update_case_attributes(attributes)
          CaseCore::Actions::Cases.update(id: c4s3.id, **attributes)
        end
      end
    end
  end
end
