# encoding: utf-8

module MFCCase
  module EventProcessors
    module Base
      module Mixins
        module Expired
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Модуль, предоставляющий пространства имён исключений, используемых
          # содержащим модулем
          #
          module Errors
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Пространство имён исключений, сигнализирующих об ошибках
            # обработки даты
            #
            module Date
              # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
              #
              # Класс исключения, создаваемого в случае, когда строка с датой
              # имеет неверный формат
              #
              class InvalidFormat < RuntimeError
                # Инициализирует объект класса
                #
                # @param [#to_s] date
                #   строка с датой
                #
                def initialize(date)
                  super(<<-MESSAGE.squish)
                    Значение `#{date}` атрибута `rejecting_expected_at` не
                    представляет собой строку, в начале которой находится дата
                    в формате `ГГГГ-ММ-ДД`
                  MESSAGE
                end
              end
            end
          end
        end
      end
    end
  end
end
