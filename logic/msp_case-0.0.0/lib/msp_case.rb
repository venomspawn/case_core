# encoding: utf-8

load "#{__dir__}/msp_case/event_processors.rb"
load "#{__dir__}/msp_case/version.rb"

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Модуль, реализующий бизнес-логику МСП-услуги
#
module MSPCase
  # Выставляет начальный статус заявки `processing` и создаёт запрос в очередь
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [RuntimeError]
  #   значение поля `type` записи заявки не равно `msp_case`
  #
  # @raise [RuntimeError]
  #   если заявка обладает выставленным статусом
  #
  def self.on_case_creation(c4s3)
    processor = EventProcessors::CaseCreationProcessor.new(c4s3)
    processor.process
  end

  # Обрабатывает ответное сообщение
  #
  # @param [Stomp::Message] message
  #   объект с информацией об ответном сообщении
  #
  # @return [Boolean]
  #   была ли обработка успешна
  #
  def self.on_responding_stomp_message(message)
    processor = EventProcessors::RespondingSTOMPMessageProcessor.new(message)
    processor.process
    true
  rescue
    false
  end

  # Выполняет следующие действия:
  #
  # *   выставляет статус заявки `closed` в том и только в том случае, если
  #     статус заявки `issuance` и значение параметра `status` равно `closed`;
  # *   выставляет значение атрибута `closed_at` равным текущим дате и времени
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [Object] status
  #   выставляемый статус заявки
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если значение параметра `status` отлично от `closed`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `NilClass` или класса
  #   `Hash`
  #
  # @raise [RuntimeError]
  #   значение поля `type` записи заявки не равно `msp_case`
  #
  # @raise [RuntimeError]
  #   если статус заявки отличен от `issuance`
  #
  def self.change_status_to(c4s3, status, params)
    processor =
      EventProcessors::ChangeStatusToProcessor.new(c4s3, status, params)
    processor.process
  end
end
