# encoding: utf-8

module MSPCase
  module EventProcessors
    class IssueProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён исключений, создаваемых
      # содержащим классом
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с записью заявки
        #
        module Case
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что аргумент `c4s3`
          # конструктора содержащего класса не является объектом класса
          # `CaseCore::Models::Case`
          #
          class BadType < ArgumentError
            # Инциализирует объект класса
            #
            def initialize
              super(<<-MESSAGE.squish)
                Аргумент `c4s3` не является объектом класса
                `CaseCore::Models::Case`
              MESSAGE
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что значение атрибута
          # `status` заявки не является допустимым
          #
          class BadStatus < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            # @param [#to_s] status
            #   статус заявки
            #
            def initialize(c4s3, status)
              super(<<-MESSAGE.squish)
                Статус `#{status}` заявки с идентификатором записи `#{c4s3.id}`
                не равен `issuance`
              MESSAGE
            end
          end
        end

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с аргументом `params`
        # конструктора содержащего класса
        #
        module Params
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что аргумент `params`
          # конструктора содержащего класса не является ни объектом класса
          # `NilClass`, ни объектом класса `Hash`
          #
          class BadType < ArgumentError
            # Инциализирует объект класса
            #
            def initialize
              super(<<-MESSAGE.squish)
                Аргумент `params` не является ни объектом класса `NilClass`,
                ни объектом класса `Hash`
              MESSAGE
            end
          end
        end
      end
    end
  end
end
