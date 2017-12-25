# encoding: utf-8

load "#{__dir__}/mfc_case/event_processors.rb"
load "#{__dir__}/mfc_case/version.rb"

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Модуль, реализующий бизнес-логику неавтоматизированной услуги
#
module MFCCase
  # Выставляет начальный статус заявки `packaging`
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если заявка обладает выставленным статусом
  #
  def self.on_case_creation(c4s3)
    processor = EventProcessors::CaseCreationProcessor.new(c4s3)
    processor.process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `pending` в том и только в том случае, если
  #     статус заявки `packaging` или `rejecting`;
  # *   выставляет значение атрибута `added_to_pending_at` равным текущему
  #     времени;
  # *   прикрепляет запись заявки к реестру передаваемой корреспонденции
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `NilClass` или класса
  #   `Hash`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если статус заявки отличен от `packaging` или `rejecting`
  #
  def self.add_to_pending_list(c4s3, params)
    processor = EventProcessors::AddToPendingListProcessor.new(c4s3, params)
    processor.process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `packaging` в том и только в том случае, если
  #     статус заявки `pending` и значение атрибута `added_to_rejecting_at`
  #     отсутствует или пусто;
  # *   выставляет статус заявки `rejecting` в том и только в том случае, если
  #     статус заявки `pending` и значение атрибута `added_to_rejecting_at`
  #     присутствует и непусто;
  # *   выставляет значение атрибута `added_to_pending_at` равным `nil`;
  # *   открепляет запись заявки от реестра передаваемой корреспонденции;
  # *   если реестр передаваемой корреспонденции пуст, то удаляет его
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `NilClass` или класса
  #   `Hash`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если статус заявки отличен от `pending`
  #
  def self.remove_from_pending_list(c4s3, params)
    processor =
      EventProcessors::RemoveFromPendingListProcessor.new(c4s3, params)
    processor.process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `issuance` в том и только в том случае, если
  #     статус заявки `processing`;
  # *   выставляет значение атрибута `responded_at` равным текущему времени;
  # *   выставляет значение атрибута `response_processor_person_id` равным
  #     значению дополнительного параметра `operator_id`;
  # *   выставляет значение атрибута `result_id` равным значению
  #     дополнительного параметра `result_id`
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `NilClass` или класса
  #   `Hash`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если статус заявки отличен от `processing`
  #
  def self.send_to_frontoffice(c4s3, params)
    processor = EventProcessors::SendToFrontOfficeProcessor.new(c4s3, params)
    processor.process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `rejecting` в том и только в том случае, если
  #     одновременно выполнены следующие условия:
  #
  #     -   статус заявки `issuance`;
  #     -   значение атрибута `rejecting_expected_at` присутствует и
  #         представляет собой строку, в начале которой находится дата в
  #         формате `ГГГГ-ММ-ДД`;
  #     -  текущая дата больше значения, записанного в атрибуте
  #        `rejecting_expected_at`;
  #
  # *   выставляет значение атрибута `added_to_rejecting_at` равным текущему
  #     времени
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `NilClass` или класса
  #   `Hash`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если статус заявки отличен от `issuance`
  #
  # @raise [RuntimeError]
  #   если значение атрибута `rejecting_expected_at` отсутствует или не
  #   представляет собой строку в вышеописанном формате
  #
  def self.reject_result(c4s3, params)
    processor = EventProcessors::RejectResultProcessor.new(c4s3, params)
    processor.process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `closed` в том и только в том случае, если
  #     статус заявки `issuance`;
  # *   выставляет значение атрибута `issuer_person_id` равным значению
  #     дополнительного параметра `operator_id`;
  # *   выставляет значение атрибута `issued_at` равным текущему времени;
  # *   выставляет значение атрибута `closed_at` равным текущему времени
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `NilClass` или класса
  #   `Hash`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если статус заявки отличен от `issuance`
  #
  def self.issue(c4s3, params)
    processor = EventProcessors::IssueProcessor.new(c4s3, params)
    processor.process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет значение поля `exported` записи реестра передаваемой
  #     корреспонденции равным `true`;
  # *   выставляет значение поля `exported_at` записи реестра передаваемой
  #     корреспонденции равным текущим дате и времени;
  # *   выставляет значение поля `exporter_id` записи реестра передаваемой
  #     корреспонденции равным значению параметру `exporter_id`;
  # *   у каждой записи заявки, прикреплённой к записи реестра передаваемой
  #     корреспонденции выполняет следующие действия:
  #
  #     +   выставляет статус заявки `processing` в том и только в том
  #         случае, если одновременно выполнены следующие условия:
  #
  #         -   статус заявки `pending`;
  #         -   значение атрибута `issue_location_type` не равно
  #             `institution`;
  #         -   значение атрибута `added_to_rejecting_at` отсутствует или
  #             пусто;
  #
  #     +   выставляет статус заявки `closed` в том и только в том случае,
  #         если одновременно выполнены следующие условия:
  #
  #         -   статус заявки `pending`;
  #         -   значение атрибута `issue_location_type` равно `institution`,
  #             или значение атрибута `added_to_rejecting_at` присутствует;
  #
  #     +   выставляет значение атрибута `docs_sent_at` равным текущему
  #         времени;
  #     +   выставляет значение атрибута `processor_person_id` равным
  #         значению дополнительного параметра `operator_id`.
  #
  # @param [CaseCore::Models::Register] register
  #   запись реестра передаваемой корреспонденции
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `register` не является объектом класса
  #   `CaseCore::Models::Register`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является ни объектом класса `NilClass`, ни
  #   объектом класса `Hash`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если среди записей заявок, прикреплённых к записи реестра передаваемой
  #   корреспонденции, нашлась запись со значением атрибута`status`, который не
  #   равен `pending`, или без атрибута `status`
  #
  def self.export_register(register, params)
    processor = EventProcessors::ExportRegisterProcessor.new(register, params)
    processor.process
  end
end
