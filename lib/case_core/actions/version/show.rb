# frozen_string_literal: true

require "#{$lib}/actions/base/action"

module CaseCore
  module Actions
    module Version
      class Show < Base::Action
        require_relative 'show/params_schema'

        # Возвращает ассоциативный массив с информацией о версии приложения и
        # модулей бизнес-логики
        # @return [Hash]
        #   результирующий ассоциативный массив
        def show
          { version: VERSION }.tap do |result|
            result[:modules] = modules if modules?
          end
        end

        private

        # Возвращает, надо ли возвращать информацию о модулях бизнес-логики
        # @return [Boolean]
        #   надо ли возвращать информацию о модулях бизнес-логики
        def modules?
          params.key?(:modules)
        end

        # Регулярное выражение для извлечения информации о названиях библиотек
        # модулей бизнес-логики и их версиях
        NAME_REGEXP = /^([a-z][a-z0-9_]*)-([0-9.]*)$/

        # Возвращает ассоциативный массив с информацией о версиях модулей
        # бизнес-логики
        # @return [Hash]
        #   результирующий ассоциативный массив
        def modules
          dirs = Dir["#{$root}/#{ENV['CC_LOGIC_DIR']}/*"]
          dirs.each_with_object({}) do |dir, memo|
            dirname = File.basename(dir)
            match_data = NAME_REGEXP.match(dirname).to_a
            memo[match_data[1]] = match_data[2] unless match_data.empty?
          end
        end
      end
    end
  end
end
