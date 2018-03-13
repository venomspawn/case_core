# frozen_string_literal: true

module CaseCore
  module API
    module REST
      module Version
        module Show
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Вспомогательный модуль, предназначенный для включения в тесты REST
          # API метода, который предоставляет информацию о версии приложения
          #
          module SpecHelper
            # JSON-схема результата, возвращаемом REST API методом
            #
            RESULT_SCHEMA = {
              type: :object,
              properties: {
                version: {
                  type: :string
                }
              },
              required: %i[
                version
              ],
              additionalProperties: false
            }.freeze

            # Возвращает JSON-схему результата работы REST API метода
            #
            # @return [Object]
            #   JSON-схема результата, возвращаемом REST API методом
            #
            def schema
              RESULT_SCHEMA
            end
          end
        end
      end
    end
  end
end
