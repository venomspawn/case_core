# frozen_string_literal: true

require_relative 'case_core/init'

# Корневое пространство имён для всех классов сервиса
module CaseCore
  # Возвращает полный путь к корневой директории сервиса
  # @return [#to_s]
  #   полный путь к корневой директории сервиса
  def self.root
    Init.settings.root
  end

  # Возвращает журнал событий или `nil`, если журнал событий не выставлен
  # @return [Logger]
  #   журнал событий
  # @return [NilClass]
  #   если журнал событий не выставлен
  def self.logger
    Init.settings.logger
  end

  # Отключает журналирование, вызывает предоставленный блок и восстанавливает
  # журналирование
  def self.loglessly
    return yield unless logger.is_a?(Logger)
    begin
      level = logger.level
      logger.level = Logger::UNKNOWN + 1
      yield
    ensure
      logger.level = level
    end
  end

  # Возвращает полный путь к директории исходных файлов сервиса
  # @return [#to_s]
  #   полный путь к директории исходных файлов сервиса
  def self.lib
    @lib ||= "#{__dir__}/#{name}"
  end

  # Название сервиса
  NAME = 'case_core'

  # Возвращает название сервиса
  # @return [String]
  #   название сервиса
  def self.name
    NAME
  end

  # Тип окружения для разработки
  DEVELOPMENT = 'development'

  # Тип окружения для тестирования
  TEST = 'test'

  # Тип окружения для продуктивного стенда
  PRODUCTION = 'production'

  # Множество типов окружений
  ENVIRONMENTS = [DEVELOPMENT, TEST, PRODUCTION].freeze

  # Возвращает значение переменной окружения `RACK_ENV` или строку
  # {DEVELOPMENT}, если значение переменной окружения `RACK_ENV` отсутствует
  # во множестве {ENVIRONMENTS}
  # @return [String]
  #   значение переменной окружения `RACK_ENV` или строка {DEVELOPMENT}, если
  #   значение переменной окружения `RACK_ENV` отсутствует во множестве
  #   {ENVIRONMENTS}
  def self.env
    value = ENV['RACK_ENV']
    ENVIRONMENTS.include?(value) ? value : DEVELOPMENT
  end

  # Возвращает, выставлено ли окружение для разработки
  # @return [Boolean]
  #   выставлено ли окружение для разработки
  def self.development?
    env == DEVELOPMENT
  end

  # Возвращает, выставлено ли окружение для тестирования
  # @return [Boolean]
  #   выставлено ли окружение для тестирования
  def self.test?
    env == TEST
  end

  # Возвращает, выставлено ли окружение для продуктивного стенда
  # @return [Boolean]
  #   выставлено ли окружение для продуктивного стенда
  def self.production?
    env == PRODUCTION
  end

  # Расширение файлов исходного кода
  RB_EXT = '.rb'

  # Пустой список
  EMPTY = [].freeze

  # Одноэлементный список, подставляемый для пропуска ошибок класса
  # `StandardError`
  SKIP_STANDARD_ERROR = [StandardError].freeze

  # Загружает один или несколько файлов исходного кода согласно маске,
  # включающей в себя частичный путь от директории по пути {lib}. Добавляет в
  # конец маски строку `.rb`, если она отсутствует. Не создаёт исключений, если
  # по маске ничего не найдено.
  # @example
  #   need 'init' — загрузка файла `init.rb`, который находится в директории
  #   {lib}
  # @example
  #   need 'models/**/*' — загрузка всех файлов исходного кода, находящихся в
  #   директории по частичному пути `models` от директории {lib} или в её
  #   дочерних директориях
  # @param [#to_s] mask
  #   маска
  # @param [NilClass, Hash] opts
  #   ассоциативный массив настроек загрузки или `nil`, если настройки
  #   отсутствуют. Поддерживаются следующие ключи.
  #   *   `:skip_errors`. На основе значения по этому ключу формируется набор
  #       классов ошибок, которые пропускаются при загрузке. Значение может
  #       быть классом, списком и булевой константой `true`. В последнем случае
  #       в качестве набора классов ошибок берётся одноэлементный список из
  #       `StandardError`. При иных значениях подставляется пустой список.
  def self.need(mask, opts = nil)
    mask = mask.to_s
    mask = "#{mask}.rb" unless mask.end_with?(RB_EXT)
    skip_errors = opts[:skip_errors] if opts.is_a?(Hash)
    skip = case skip_errors
           when Class     then [skip_errors]
           when Array     then skip_errors
           when TrueClass then SKIP_STANDARD_ERROR
           else                EMPTY
           end
    Dir["#{lib}/#{mask}"].each { |path| require_file(path, skip) }
  end

  # Загружает файл по предоставленному пути. При возникновении ошибок
  # пропускает их, если их классы находятся в предоставленном наборе.
  # @param [to_s] path
  #   путь до файла
  # @param [#include?] skip
  #   набор классов ошибок, которые должны быть пропущены при загрузке
  def self.require_file(path, skip = EMPTY)
    require path.to_s
  rescue StandardError => error
    raise error if error.class.ancestors.find(&skip.method(:include?)).nil?
  end
end
