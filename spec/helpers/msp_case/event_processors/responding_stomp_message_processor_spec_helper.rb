# encoding: utf-8

module MSPCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MSPCase::EventProcessors::RespondingSTOMPMessageProcessor`
    #
    module RespondingSTOMPMessageProcessorSpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] status
      #   статус заявки
      #
      # @param [Object] issue_location_type
      #   тип места выдачи результата заявки
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(status, issue_location_type)
        FactoryGirl.create(:case, type: 'msp_case').tap do |c4s3|
          FactoryGirl.create(:case_attributes, case: c4s3, status: status)
          args = { issue_location_type: issue_location_type }
          FactoryGirl.create(:case_attributes, case: c4s3, **args)
        end
      end

      # Возвращает ассоциативный массив атрибутов заявки с предоставленным
      # идентификатором записи заявки
      #
      # @param [Object] case_id
      #   идентификатор записи заявки
      #
      # @return [Hash{Symbol => Object}]
      #   результирующий ассоциативный массив
      #
      def case_attributes(case_id)
        CaseCore::Actions::Cases.show_attributes(id: case_id)
      end

      # Возвращает значение атрибута `status` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `status` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      #
      def case_status(c4s3)
        case_attributes(c4s3.id)[:status]
      end

      # Возвращает значение атрибута `closed_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `closed_at` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      #
      def case_closed_at(c4s3)
        value = case_attributes(c4s3.id)[:closed_at]
        value && Time.parse(value)
      end

      # Создаёт и возвращает запись запроса, прикреплённую к записи заявки, с
      # предоставленным значением атрибута `msp_message_id`
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [Object] msp_message_id
      #   значение атрибута `msp_message_id` запроса
      #
      def create_request(c4s3, msp_message_id)
        CaseCore::Actions::Requests
          .create(case_id: c4s3.id, msp_message_id: msp_message_id)
      end

      # Возвращает ассоциативный массив атрибутов запроса с предоставленным
      # идентификатором записи
      #
      # @param [Object] request_id
      #   идентификатор записи заявки
      #
      # @return [Hash{Symbol => Object}]
      #   результирующий ассоциативный массив
      #
      def request_attributes(request_id)
        CaseCore::Actions::Requests.show(id: request_id)
      end

      # Возвращает значение атрибута `response_content` запроса
      #
      # @param [CaseCore::Models::Request] request
      #   запись запроса
      #
      # @return [NilClass, String]
      #   значение атрибута `response_content` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def request_response_content(request)
        request_attributes(request.id)['response_content']
      end
    end
  end
end
