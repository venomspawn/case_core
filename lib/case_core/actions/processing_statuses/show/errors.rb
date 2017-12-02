# encoding: utf-8

module CaseCore
  module Actions
    module ProcessingStatuses
      class Show
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий родительскому классу классы исключений
        #
        module Errors
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключения, которое сообщает о том, что запись модели
          # {CaseCore::Models::ProcessingStatus} не найдена по предоставленному
          # значению атрибута `message_id`
          #
          class NotFound < Sequel::NoMatchingRow
            # Инициализирует объект класса
            #
            # @param [#to_s] message_id
            #   значение атрибута `message_id`
            #
            def initialize(message_id)
              super(<<-MESSAGE.squish)
                Запись модели #{Models::ProcessingStatus} не найдена по
                значению #{message_id} атрибута `message_id`
              MESSAGE
            end
          end
        end
      end
    end
  end
end
