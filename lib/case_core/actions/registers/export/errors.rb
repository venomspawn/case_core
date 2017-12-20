# encoding: utf-8

module CaseCore
  module Actions
    module Registers
      class Export
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль пространств имён классов ошибок, используемых содержащим
        # классом
        #
        module Errors
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Пространство имён классов ошибок, связанных с реестрами
          # передаваемой корреспонденции
          #
          module Register
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс ошибок, сигнализирующих, что реестр передаваемой
            # корреспонденции пуст
            #
            class Empty < RuntimeError
              # Инициализирует объект класса
              #
              # @param [#to_s] id
              #   идентификатор записи реестра передаваемой корреспонденции
              #
              def initialize(id)
                super(<<-MESSAGE.squish)
                  Реестр передаваемой корреспонденции с идентификатором записи
                  `#{id}` пуст
                MESSAGE
              end
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Пространство имён классов ошибок, связанных с бизнес-логикой заявок
          #
          module Logic
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс ошибок, сигнализирующих, что невозможно найти модуль
            # бизнес-логики для данной заявки
            #
            class Absent < RuntimeError
              # Инициализирует объект класса
              #
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
              #
              def initialize(c4s3)
                super(<<-MESSAGE.squish)
                  Невозможно найти модуль бизнес-логики для заявки типа
                  `#{c4s3.type}` с идентификатором записи `#{c4s3.id}`
                MESSAGE
              end
            end
          end
        end
      end
    end
  end
end
