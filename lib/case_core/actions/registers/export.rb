# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Registers::Export =
  Class.new(CaseCore::Actions::Base::Action)

require_relative 'export/errors'
require_relative 'export/params_schema'

module CaseCore
  module Actions
    module Registers
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями реестров передаваемой корреспонденции,
      # предоставляющий метод `export`, который находит заявку в реестре
      # передаваемой корреспонденции и вызывает функцию `export_register` у
      # модуля бизнес-логики этой заявки с записью реестра в качестве аргумента
      #
      class Export
        include ParamsSchema

        # Находит заявку в реестре передаваемой корреспонденции с данным
        # идентификатором записи и вызывает функцию `export_register` у модуля
        # бизнес-логики, обрабатывающей заявку, с записью реестра в качестве
        # аргумента
        #
        # @raise [Sequel::NoMatchingRow]
        #   если невозможно найти запись реестра передаваемой корреспонденции
        #   по предоставленному в параметре `id` идентификатору
        #
        # @raise [RuntimeError]
        #   если в реестре передаваемой корреспонденции нет заявок
        #
        # @raise [RuntimeError]
        #   если невозможно найти модуль бизнес-логики по записи заявки
        #
        def export
          logic.send(:export_register, register)
        end

        private

        # Возвращает значение параметра `id` действия
        #
        # @return [Object]
        #   значение параметра `id` действия
        #
        def id
          params[:id]
        end

        # Возвращает запись реестра передаваемой корреспонденции по
        # предоставленному в параметре `id` идентификатора
        #
        # @return [CaseCore::Models::Register]
        #   запись реестра передаваемой корреспонденции
        #
        # @raise [Sequel::NoMatchingRow]
        #   если невозможно найти запись реестра передаваемой корреспонденции
        #   по предоставленному в параметре `id` идентификатору
        #
        def register
          @register ||= Models::Register.with_pk!(id)
        end

        # Возвращает первую запись заявки в реестре
        #
        # @return [CaseCore::Models::Case]
        #   первая запись заявки в реестре
        #
        # @raise [RuntimeError]
        #   если в реестре передаваемой корреспонденции нет заявок
        #
        def c4s3
          @c4s3 ||= register.cases_dataset.first.tap(&method(:check_case!))
        end

        # Проверяет, что аргумент не равен `nil`
        #
        # @param [Object] c4s3
        #   аргумент
        #
        # @raise [RuntimeError]
        #   если аргумент равен `nil`
        #
        def check_case!(c4s3)
          raise Errors::Register::Empty.new(id) if c4s3.nil?
        end

        # Возвращает модуль бизнес-логики, обрабатывающей запись первой заявки
        # в реестре передаваемой корреспонденции
        #
        # @return [Module]
        #   модуль бизнес-логики, обрабатывающий запись первой заявки в реестре
        #   передаваемой корреспонденции
        #
        # @raise [RuntimeError]
        #   если невозможно найти модуль бизнес-логики по записи заявки
        #
        def logic
          Logic::Loader.logic(c4s3.type).tap(&method(:check_logic!))
        end

        # Проверяет, что аргумент не равен `nil`
        #
        # @param [Object] logic
        #   аргумент
        #
        # @raise [RuntimeError]
        #   если аргумент равен `nil`
        #
        def check_logic!(logic)
          raise Errors::Logic::Absent.new(c4s3) if logic.nil?
        end
      end
    end
  end
end
