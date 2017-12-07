# encoding: utf-8

module CaseCore
  module Logic
    class Loader
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс вспомогательных объектов, позволяющий осуществлять проверки на
      # наличие обновлений модуля бизнес-логики
      #
      class Utils
        # Инициализирует объект класса
        #
        # @param [#to_s] dir
        #   путь к директории, в которой ищутся библиотеки с бизнес-логикой
        #
        # @param [#to_s] name
        #   название модуля в змеином_регистре
        #
        # @param [CaseCore::Logic::Loader::ModuleInfo] module_info
        #   объект с информацией о модуле
        #
        def initialize(dir, name, module_info)
          @dir             = dir.to_s
          @name            = name.to_s
          @module_info     = module_info
        end

        # Возвращает, необходимо ли осуществлять перезагрузку модуля из внешней
        # библиотеки
        #
        # @return [Boolean]
        #   необходимо ли осуществлять перезагрузку модуля из внешней
        #   библиотеки
        #
        def reload?
          dir_changed? && version_changed?
        end

        # Возвращает путь к файлу с модулем бизнес-логики
        #
        # @return [String]
        #   путь к файлу с модулем бизнес-логики
        #
        def filename
          "#{lib_dir_prefix}#{last_lib_version}/lib/#{name}.rb"
        end

        # Возвращает строку с последней версии библиотеки, в которой находится
        # модуль бизнес-логики, или `nil`, если такая библиотека отсутствует
        #
        # @return [NilClass, String]
        #   строка с последней версии библиотеки, в которой находится модуль
        #   бизнес-логики, или `nil`, если такая библиотека отсутствует
        #
        def last_lib_version
          @last_version ||=
            Dir["#{lib_dir_prefix}*"]
            .map { |path| path[lib_dir_prefix.size..-1] }
            .sort
            .last
        end

        private

        # Путь к директории, в которой ищутся библиотеки с бизнес-логикой
        #
        # @return [String]
        #   путь к директории, в которой ищутся библиотеки с бизнес-логикой
        #
        attr_reader :dir

        # Название модуля в змеином_регистре
        #
        # @return [String]
        #   название модуля в змеином_регистре
        #
        attr_reader :name

        # Объект с информацией о модуле
        #
        # @return [CaseCore::Logic::Loader::ModuleInfo]
        #   объект с информацией о модуле
        #
        attr_reader :module_info

        # Возвращает время создания объекта с информацией о модуле
        #
        # @return [Time]
        #   время создания объекта с информацией о модуле
        #
        def module_time
          module_info.time
        end

        # Возвращает строку с версией модуля
        #
        # @return [String]
        #   строка с версией модуля
        #
        def module_version
          module_info.version
        end

        # Возвращает, изменилось ли содержимое директории, в которой находится
        # библиотека с модулем
        #
        # @return [Boolean]
        #   изменилось ли содержимое директории, в которой находится библиотека
        #   с модулем
        #
        def dir_changed?
          module_time < File.mtime(dir)
        end

        # Возвращает, найдена ли библиотека с модулем более новой версии, чем
        # версия модуля
        #
        # @return [Boolean]
        #   найдена ли библиотека с модулем более новой версии, чем версия
        #   модуля
        #
        def version_changed?
          lib_version = last_lib_version
          lib_version.present? && module_version != lib_version
        end

        # Возвращает строку с начальной частью пути до библиотеки с модулем
        #
        # @return [String]
        #   результирующая строка
        #
        def lib_dir_prefix
          @lib_dir_prefix ||= "#{dir}/#{name}-"
        end
      end
    end
  end
end
