# encoding: utf-8

require "#{$lib}/helpers/log"

require_relative 'errors'

module CaseCore
  module Logic
    class Fetcher
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Вспомогательный модуль, содержащий пространства имён классов
      # исключений, которые используются объектами содержащего класса
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён для классов исключений, возникающих при проверке
        # информации о последней версии библиотеки
        #
        module Version
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, создаваемых в случае, когда на сервере библиотек
          # отсутствует информация о последней версии библиотеки
          #
          class Nil < RuntimeError
            # Инициализирует объект класса
            #
            # @param [#to_s] name
            #   название библиотеки
            #
            def initialize(name)
              super(<<-MESSAGE.squish)
                Не найдена информация о последней версии библиотеки с названием
                `#{name}` на сервере библиотек
              MESSAGE
            end
          end
        end

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён для классов исключений, возникающих при проверке,
        # что тело файла с библиотекой было загружено с сервера библиотек
        #
        module Gem
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, создаваемых в случае, когда тело файла не было
          # загружено с сервера библиотек
          #
          class Nil < RuntimeError
            # Инициализирует объект класса
            #
            # @param [#to_s] name
            #   название библиотеки
            #
            # @param [#to_s] version
            #   версия библиотеки
            #
            def initialize(name, version)
              super(<<-MESSAGE.squish)
                Тело файла с библиотекой с названием `#{name}` и версией
                `#{version}` не было загружено с сервера библиотек
              MESSAGE
            end
          end
        end

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён для классов исключений, возникающих при проверке,
        # что в файле с библиотекой найден архив, хранящий файлы библиотеки
        #
        module PackedDataEntry
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, создаваемых в случае, когда в файле с библиотекой
          # не найден архив, хранящий файлы библиотеки
          #
          class Nil < RuntimeError
            # Инициализирует объект класса
            #
            # @param [#to_s] name
            #   название библиотеки
            #
            # @param [#to_s] version
            #   версия библиотеки
            #
            def initialize(name, version)
              super(<<-MESSAGE.squish)
                В теле файла с библиотекой с названием `#{name}` и версией
                `#{version}` не найден архив с файлами библиотеки
              MESSAGE
            end
          end
        end
      end
    end
  end
end
