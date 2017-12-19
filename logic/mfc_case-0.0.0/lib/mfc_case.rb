# encoding: utf-8

require_relative 'mfc_case/event_processors/add_to_pending_list_processor'
require_relative 'mfc_case/event_processors/case_creation_processor'
require_relative 'mfc_case/event_processors/close_processor'
require_relative 'mfc_case/event_processors/reject_result_processor'
require_relative 'mfc_case/event_processors/send_to_frontoffice_processor'
require_relative 'mfc_case/event_processors/send_to_institution_processor'

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
  def on_case_creation(c4s3)
    EventProcessors::CaseCreationProcessor.new(c4s3).process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `pending` в том и только в том случае, если
  #     статус заявки `packaging` или `rejecting`;
  # *   выставляет значение атрибута `added_to_pending_at` равным текущему
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
  #   если статус заявки отличен от `packaging` или `rejecting`
  #
  def add_to_pending_list!(c4s3, params)
    EventProcessors::AddToPendingListProcessor.new(c4s3, params).process
  end

  # Выполняет те же действия, что и {add_to_pending_list!} и возвращает, были
  # ли они выполнены без ошибок
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @return [Boolean]
  #   были ли выполнены действия без ошибок
  #
  def add_to_pending_list(c4s3, params)
    add_to_pending_list!(c4s3, params)
    true
  rescue
    false
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `processing` в том и только в том случае, если
  #     одновременно выполнены следующие условия:
  #
  #     -   статус заявки `packaging` или `pending`;
  #     -   значение атрибута `issue_location_type` не равно `institution`;
  #     -   значение атрибута `added_to_rejecting_at` отсутствует или пусто;
  #
  # *   выставляет статус заявки `closed` в том и только в том случае, если
  #     одновременно выполнены следующие условия:
  #
  #     -   статус заявки `packaging` или `pending`;
  #     -   значение атрибута `issue_location_type` равно `institution`, или
  #         значение атрибута `added_to_rejecting_at` присутствует;
  #
  # *   выставляет значение атрибута `docs_sent_at` равным текущему времени;
  # *   выставляет значение атрибута `processor_person_id` равным значению
  #     дополнительного параметра `operator_id`.
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
  #   если статус заявки отличен от `packaging` или `pending`
  #
  def send_to_institution!(c4s3, params)
    EventProcessors::SendToInstitutionProcessor.new(c4s3, params).process
  end

  # Выполняет те же действия, что и {send_to_institution!} и возвращает, были
  # ли они выполнены без ошибок
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @return [Boolean]
  #   были ли выполнены действия без ошибок
  #
  def send_to_institution(c4s3, params)
    send_to_institution!(c4s3, params)
    true
  rescue
    false
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
  #   если статус заявки отличен от `processing`
  #
  def send_to_frontoffice!(c4s3, params)
    EventProcessors::SendToFrontOfficeProcessor.new(c4s3, params)
  end

  # Выполняет те же действия, что и {send_to_frontoffice!} и возвращает, были
  # ли они выполнены без ошибок
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @return [Boolean]
  #   были ли выполнены действия без ошибок
  #
  def send_to_frontoffice(c4s3, params)
    send_to_frontoffice!(c4s3, params)
    true
  rescue
    false
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
  #   если статус заявки отличен от `issuance`
  #
  # @raise [RuntimeError]
  #   если значение атрибута `rejecting_expected_at` отсутствует или не
  #   представляет собой строку в вышеописанном формате
  #
  def reject_result!(c4s3, params)
    EventProcessors::RejectResultProcessor.new(c4s3, params).process
  end

  # Выполняет те же действия, что и {reject_result!} и возвращает, были ли они
  # выполнены без ошибок
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @return [Boolean]
  #   были ли выполнены действия без ошибок
  #
  def reject_result(c4s3, params)
    reject_result!(c4s3, params)
    true
  rescue
    false
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `closed` в том и только в том случае, если
  #     статус заявки `rejecting` или `issuance`;
  # *   если предыдущий статус заявки был `rejecting`, то выставляет значение
  #     атрибута `rejector_person_id` равным значению
  #     дополнительного параметра `operator_id`;
  # *   если предыдущий статус заявки был `rejecting`, то выставляет значение
  #     атрибута `rejected_at` равным текущему времени;
  # *   если предыдущий статус заявки был `issuance`, то выставляет значение
  #     атрибута `issuer_person_id` равным значению дополнительного параметра
  #     `operator_id`;
  # *   если предыдущий статус заявки был `issuance`, то выставляет значение
  #     атрибута `issued_at` равным текущему времени;
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
  #   если статус заявки отличен от `processing`
  #
  def close!(c4s3, params)
    EventProcessors::CloseProcessor.new(c4s3, params).process
  end

  # Выполняет те же действия, что и {close!} и возвращает, были ли они
  # выполнены без ошибок
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @return [Boolean]
  #   были ли выполнены действия без ошибок
  #
  def close(c4s3, params)
    close!(c4s3, params)
    true
  rescue
    false
  end
end
