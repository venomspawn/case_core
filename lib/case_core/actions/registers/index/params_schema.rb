# encoding: utf-8

module CaseCore
  module Actions
    module Registers
      class Index
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий пространство имён для константы, в которой
        # задаётся схема параметров действия родительского класса
        #
        module ParamsSchema
          # Схема параметров действия
          #
          PARAMS_SCHEMA = {
            type: :object,
            properties: {
              filter: {
                type: :object,
                properties: {
                  institutution_rguid: {
                    type: %i(string number boolean null array),
                    items: {
                      type: %i(string number boolean  null)
                    }
                  },
                  office_id: {
                    type: %i(string number boolean null array),
                    items: {
                      type: %i(string number boolean null)
                    }
                  },
                  back_office_id: {
                    type: %i(string number boolean null array),
                    items: {
                      type: %i(string number boolean null)
                    }
                  },
                  register_type: {
                    type: :string
                  },
                  exported: {
                    type: %i(boolean null array),
                    items: {
                      type: %i(boolean null)
                    }
                  },
                  exporter_id: {
                    type: %i(string number boolean null array),
                    items: {
                      type: %i(string number boolean null)
                    }
                  },
                  exported_at: {
                    type: :any
                  }
                },
                additionalProperties: false
              }
            }
          }
        end
      end
    end
  end
end
