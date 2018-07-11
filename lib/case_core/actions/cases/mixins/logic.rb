# frozen_string_literal: true

module CaseCore
  need 'helpers/log'

  module Actions
    module Cases
      # Пространство имён для подключаемых модулей
      module Mixins
        # Модуль, предоставляющий метод `logic` для извлечения модуля
        # бизнес-логики по значению поля `type` записи заявки
        module Logic
          include Helpers::Log

          private

          # Сообщение о том, что аргумент не является записью модели
          # `CaseCore::Models::Case`
          NOT_A_CASE =
            'Аргумент не является записью модели `CaseCore::Models::Case`'

          # Возвращает модуль бизнес-логики для записи заявки по значению поля
          # `type` или `nil`, если модуль бизнес логики невозможно найти
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки
          # @return [Module]
          #   модуль бизнес-логики
          # @return [NilClass]
          #   если модуль бизнес-логики невозможно найти
          # @raise [ArgumentError]
          #   если аргумент не является объектом типа {CaseCore::Models::Case}
          def logic(c4s3)
            raise ArgumentError, NOT_A_CASE unless c4s3.is_a?(Models::Case)
            result = CaseCore::Logic::Loader.logic(c4s3.type)
            result.tap { log_warn(binding) { <<-LOG } if result.nil? }
              Невозможно найти модуль бизнес-логики для заявки типа
              `#{c4s3.type}` с идентификатором записи `#{c4s3.id}`
            LOG
          end
        end
      end
    end
  end
end
