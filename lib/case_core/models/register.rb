# encoding: utf-8

module CaseCore
  module Models
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модель реестра передаваемой корреспонденции
    #
    # @!attribute id
    #   Идентификатор записи
    #
    #   @return [Integer]
    #     идентификатор записи
    #
    #
    # @!attribute institution_rguid
    #   RGUID ведомства, в которое отправляется реестр
    #
    #   @return [String]
    #     RGUID ведомства, в которое отправляется реестр
    #
    #   @return [NilClass]
    #     если отсутствует информация о ведомстве, в которое отправляется
    #     реестр
    #
    #
    # @!attribute office_id
    #   Идентификатор офиса, в который отправляется реестр
    #
    #   @return [String]
    #     идентификатор офиса, в который отправляется реестр
    #
    #   @return [NilClass]
    #     если отсутствует информация об идентификаторе офиса, в который
    #     отправляется реестр
    #
    #
    # @!attribute back_office_id
    #   Идентификатор записи офиса, из которого отправляется реестр
    #
    #   @return [String]
    #     идентификатор записи офиса, из которого отправляется реестр
    #
    #   @return [NilClass]
    #     если отсутствует информация о записи офиса, из которого отправляется
    #     реестр
    #
    #
    # @!attribute register_type
    #   Тип реестра
    #
    #   @return ['cases']
    #     если реестр содержит заявки
    #
    #   @return ['requests']
    #     если реестр содержит запросы
    #
    #
    # @!attribute exported
    #   Отправлен ли реестр
    #
    #   @return [Boolean]
    #     отправлен ли реестр
    #
    #   @return [NilClass]
    #     если отсутствует информация о том, отправлен ли реестр
    #
    #
    # @!attribute exported_id
    #   Идентификатор оператора, отправившего реестр
    #
    #   @return [String]
    #     идентификатор оператора, отправившего реестр
    #
    #   @return [NilClass]
    #     если отсутствует информация об идентификаторе оператора, отправившего
    #     реестр
    #
    #
    # @!attribute exported_at
    #   Дата и время отправки реестра
    #
    #   @return [Time]
    #     дата и время отправки реестра
    #
    #   @return [NilClass]
    #     если отсутствует информация о дате и времени отправки реестра
    #
    #
    # @!attribute cases
    #   Список записей заявок, находящихся в реестре
    #
    #   @return [Array<CaseCore::Models::Case>]
    #     список записей заявок, находящихся в реестре
    #
    #
    # @!attribute cases_dataset
    #   Запрос на получение записей заявок, находящихся в реестре
    #
    #   @return [Sequel::Dataset]
    #     запрос на получение записей заявок, находящихся в реестре
    #
    #
    # @!attribute case_registers
    #   Список записей связей между заявками и реестром
    #
    #   @return [Array<CaseCore::Models::CaseRegister>]
    #     список записей связей между заявками и реестром
    #
    #
    # @!attribute case_registers_dataset
    #   Запрос на получение запией связей между заявками и реестром
    #
    #   @return [Sequel::Dataset]
    #     запрос на получение записей связей между заявками и реестром
    #
    class Register < Sequel::Model
      # Отношения
      many_to_many :cases, join_table: :case_registers
      one_to_many  :case_registers

      # Обновляет запись модели
      #
      # @param [Hash] values
      #   новые атрибуты записи
      #
      # @return [Boolean]
      #   удалось или нет сохранить запись
      #
      def update(values)
        model.restrict_primary_key unless model.restrict_primary_key?
        super
      end
    end
  end
end
