# frozen_string_literal: true

require "#{$lib}/actions/base/action"

require_relative 'mixins/logic'

module CaseCore
  module Actions
    module Cases
      # Класс действий над записями заявок, предоставляющих метод `call`,
      # который вызывает метод модуля бизнес-логики с записью заявки в качестве
      # аргумента
      class Call < Base::Action
        require_relative 'call/errors'
        require_relative 'call/params_schema'

        include Cases::Mixins::Logic

        # Вызывает метод модуля бизнес-логики с записью заявки в качестве
        # аргумента
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена по предоставленному идентификатору
        # @raise [RuntimeError]
        #   если модуль бизнес-логики не найден по типу заявки
        def call
          obj = logic(c4s3) || (raise Errors::Logic::Absent.new(c4s3))
          obj.send(method_name, c4s3, *arguments)
        end

        private

        # Возвращает идентификатор заявки
        # @return [Object]
        #   идентификатор заявки
        def id
          params[:id]
        end

        # Возвращает название метода
        # @return [String]
        #   название метода
        def method_name
          params[:method].to_s
        end

        # Возвращает список дополнительных аргументов метода
        # @return [Array]
        #   список дополнительных аргументов метода
        def arguments
          params[:arguments] || []
        end

        # Возвращает запись заявки
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена по предоставленному идентификатору
        #   {id}
        def c4s3
          @c4s3 ||= Models::Case.with_pk!(id)
        end
      end
    end
  end
end
