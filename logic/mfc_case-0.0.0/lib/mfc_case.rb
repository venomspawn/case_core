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

  def add_to_pending_list!(c4s3, params)
    EventProcessors::AddToPendingListProcessor.new(c4s3, params).process
  end

  def add_to_pending_list(c4s3, params)
    add_to_pending_list!(c4s3, params)
    true
  rescue
    false
  end

  def send_to_institution!(c4s3, params)
    EventProcessors::SendToInstitutionProcessor.new(c4s3, params).process
  end

  def send_to_institution(c4s3, params)
    send_to_institution!(c4s3, params)
    true
  rescue
    false
  end

  def send_to_frontoffice!(c4s3, params)
    EventProcessors::SendToFrontOfficeProcessor.new(c4s3, params)
  end

  def send_to_frontoffice(c4s3, params)
    send_to_frontoffice!(c4s3, params)
    true
  rescue
    false
  end

  def reject_result!(c4s3, params)
    EventProcessors::RejectResultProcessor.new(c4s3, params).process
  end

  def reject_result(c4s3, params)
    reject_result!(c4s3, params)
    true
  rescue
    false
  end

  def close!(c4s3, params)
    EventProcessors::CloseProcessor.new(c4s3, params).process
  end

  def close(c4s3, params)
    close!(c4s3, params)
    true
  rescue
    false
  end
end
