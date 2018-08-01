# frozen_string_literal: true

require 'rack/common_logger'

module CaseCore
  module API
    module REST
      # Класс журнала событий, используемым `Rack`
      class Logger < Rack::CommonLogger
        # Инициализирует экземпляр класса
        # @param [#call] app
        #   приложение Rack
        def initialize(app)
          super(app, CaseCore.logger)
        end

        # Вызывается `Rack`
        # @param [Hash] env
        #   ассоциативный массив параметров `Rack`
        def call(env)
          black_listed?(env) ? @app.call(env) : super
        end

        # Множество путей, запросы на которые не журналируются
        BLACK_LIST = %w[/version /processing_statuses].freeze

        # Возвращает, пропустить ли журналирование запроса на путь
        # @param [Hash] env
        #   ассоциативный массив параметров `Rack`
        # @return [Boolean]
        #   пропустить ли журналирование запроса на путь
        def black_listed?(env)
          BLACK_LIST.any?(&env['PATH_INFO'].method(:start_with?))
        end
      end
    end
  end
end
