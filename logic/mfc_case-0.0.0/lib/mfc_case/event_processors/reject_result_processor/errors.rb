# encoding: utf-8

module MFCCase
  module EventProcessors
    class RejectResultProcessor < Base::CaseEventProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён исключений, используемых
      # содержащим классом
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, сигнализирующих об ошибках обработки
        # даты
        #
        module Date
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключения, создаваемого в случае, когда дата возврата
          # результата заявки ещё не наступила
          #
          class NotExpired < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            def initialize(c4s3)
              super(<<-MESSAGE.squish)
                Дата возврата результата заявки с идентификатором `#{c4s3.id}`
                ещё не наступила
              MESSAGE
            end
          end
        end
      end
    end
  end
end