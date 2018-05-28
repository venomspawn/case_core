# frozen_string_literal: true

require 'rack/common_logger'
require 'set'

module CaseCore
  module API
    module REST
      # Класс журнала событий, используемым `Rack`
      class Logger < Rack::CommonLogger
        # Инициализирует экземпляр класса
        # @param [#call] app
        #   приложение Rack
        def initialize(app)
          super(app, $logger)
        end

        # Множество путей, запросы на которые не журналируются
        BLACK_LIST = %w[/version].to_set.freeze

        # Вызывается `Rack`
        # @param [Hash] env
        #   ассоциативный массив параметров `Rack`
        def call(env)
          black_listed?(env) ? @app.call(env) : super
        end

        # Возвращает, пропустить ли журналирование запроса на путь
        # @param [Hash] env
        #   ассоциативный массив параметров `Rack`
        # @return [Boolean]
        #   пропустить ли журналирование запроса на путь
        def black_listed?(env)
          BLACK_LIST.include?(env['PATH_INFO'])
        end
      end
    end
  end
end
