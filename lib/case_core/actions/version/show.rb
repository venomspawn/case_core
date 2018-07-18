# frozen_string_literal: true

module CaseCore
  need 'actions/base/action'
  need 'version'

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
        NAME_REGEXP = /\A([a-z][a-z0-9_]*)-([0-9.]*)\z/

        # Возвращает ассоциативный массив с информацией о версиях модулей
        # бизнес-логики
        # @return [Hash]
        #   результирующий ассоциативный массив
        def modules
          dirs = Dir["#{CaseCore.root}/#{ENV['CC_LOGIC_DIR']}/*"]
          dirs.each_with_object({}, &method(:process_dir))
        end

        # Заполняет ассоциативный массив с информацией о версиях модулей
        # бизнес-логики на основе названия директории с библиотекой
        # бизнес-логики
        # @param [String] path
        #   путь к директории с библиотекой бизнес-логики
        # @param [Hash]
        #   ассоциативный массив с информацией о версиях модулей бизнес-логики
        def process_dir(path, memo)
          dirname = File.basename(path)
          match_data = NAME_REGEXP.match(dirname).to_a
          return if match_data.empty?
          name = match_data[1]
          version = match_data[2]
          current = memo[name]
          return if current.present? && current > version
          memo[name] = version
        end
      end
    end
  end
end
