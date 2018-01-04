# encoding: utf-8

module MSPCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MSPCase::EventProcessors::IssueProcessor`
    #
    module IssueProcessorSpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] status
      #   статус заявки
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(status)
        FactoryGirl.create(:case, type: 'msp_case').tap do |c4s3|
          FactoryGirl.create(:case_attributes, case: c4s3, status: status)
        end
      end

      # Возвращает ассоциативный массив атрибутов заявки с предоставленным
      # идентификатором записи заявки
      #
      # @param [Object] case_id
      #   идентификатор записи заявки
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
    end
  end
end
