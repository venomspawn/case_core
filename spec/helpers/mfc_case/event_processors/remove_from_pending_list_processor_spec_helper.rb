# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::EventProcessors::RemoveFromPendingListProcessor`
    #
    module RemoveFromPendingListProcessorSpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] status
      #   статус заявки
      #
      # @param [Object] added_to_rejecting_at
      #   дата добавления в состояние `rejecting`
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(status, added_to_rejecting_at)
        FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
          attributes = {
            status:                status,
            added_to_rejecting_at: added_to_rejecting_at
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

      # Возвращает значение атрибута `added_to_pending_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `added_to_pending_at` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def case_added_to_pending_at(c4s3)
        value = case_attributes(c4s3.id).dig(:added_to_pending_at)
        value && Time.parse(value)
      end

      # Связывает записи реестра передаваемой корреспонденции и заявок
      #
      # @param [CaseCore::Models::Register] register
      #   запись реестра передаваемой корреспонденции
      #
      # @param [Array<CaseCore::Models::Case>] cases
      #   список записей заявок
      #
      def put_cases_into_register(register, *cases)
        cases.map do |c4s3|
          CaseCore::Models::CaseRegister.create(case: c4s3, register: register)
        end
      end

      # Возвращает запрос Sequel на получение всех записей реестров
      # передаваемой корреспонденции
      #
      # @return [Sequel::Dataset]
      #   результирующий запрос Sequel
      #
      def registers
        CaseCore::Models::Register.dataset
      end

      # Возвращает запрос Sequel на полученеи всех записей связей между
      # записями заявок и записями реестров передаваемой корреспонденции
      #
      # @return [Sequel::Dataset]
      #   результирующий запрос Sequel
      #
      def case_registers
        CaseCore::Models::CaseRegister.dataset
      end
    end
  end
end
