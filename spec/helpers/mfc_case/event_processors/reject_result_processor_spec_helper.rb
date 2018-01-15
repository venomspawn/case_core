# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::EventProcessors::RejectResultProcessor`
    #
    module RejectResultProcessorSpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] status
      #   статус заявки
      #
      # @param [Object] rejecting_expected_at
      #   дата, после которой результат заявки невозможно выдать
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(status, rejecting_expected_at)
        FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
          attributes = {
            status:                status,
            rejecting_expected_at: rejecting_expected_at
          }
          FactoryGirl.create(:case_attributes, case: c4s3, **attributes)
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
        case_attributes(c4s3.id).dig(:status)
      end

      # Возвращает значение атрибута `added_to_rejecting_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `added_to_rejecting_at` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def case_added_to_rejecting_at(c4s3)
        value = case_attributes(c4s3.id).dig(:added_to_rejecting_at)
        value && Time.parse(value)
      end
    end
  end
end