# encoding: utf-8

require "#{$lib}/censorship/filter"
require "#{$lib}/helpers/log"

module CaseCore
  module Requests
    module Base
      module Wrappers
        class RestClientWrapper
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Модуль, предназначенный для включения в родительский класс
          #
          module Helpers
            include CaseCore::Helpers::Log

            private

            # Строка, возвращаемая методом {url} в случае, когда значение
            # параметра `:url` не приведено
            #
            UNSPECIFIED_URL = '<UNSPECIFIED URL>'

            # Строка, возвращаемая методом {url} в случае, когда значение
            # параметра `:url` равно `nil`
            #
            NIL_URL = '<NIL URL>'

            # Строка, возвращаемая методом {url} в случае, когда строковое
            # значение параметра `:url` равно пустой строке
            #
            EMPTY_URL = '<EMPTY URL>'

            # Возвращает следующее значение.
            #
            # 1.  Если значение параметра `:url` не приведено, то возвращает
            #     значение константы {UNSPECIFIED_URL}.
            # 2.  Если значение параметра `:url` приведено, но равно `nil`, то
            #     возвращает значение константы {NIL_URL}.
            # 3.  Если значение параметра `:url` приведено, но равно в
            #     строковом виде пустой строке, то возвращает значение
            #     константы {EMPTY_URL}.
            # 4.  В остальных случаях возвращает значение параметра `:url`.
            #
            # @return [Object]
            #   результирующее значение
            #
            def url
              return UNSPECIFIED_URL unless request_params.key?(:url)
              return NIL_URL         if request_params[:url].nil?
              return EMPTY_URL       if request_params[:url].to_s.empty?
              request_params[:url]
            end


            # Строка, возвращаемая методом {method} в случае, когда значение
            # параметра `:method` не приведено
            #
            UNSPECIFIED_METHOD = '<UNSPECIFIED METHOD>'

            # Строка, возвращаемая методом {method} в случае, когда значение
            # параметра `:method` равно `nil`
            #
            NIL_METHOD = '<NIL METHOD>'

            # Строка, возвращаемая методом {method} в случае, когда строковое
            # значение параметра `:method` равно пустой строке
            #
            EMPTY_METHOD = '<EMPTY METHOD>'

            # Возвращает следующее значение.
            #
            # 1.  Если значение параметра `:method` не приведено, то возвращает
            #     значение константы {UNSPECIFIED_METHOD}.
            # 2.  Если значение параметра `:method` приведено, но равно `nil`,
            #     то возвращает значение константы {NIL_METHOD}.
            # 3.  Если значение параметра `:method` приведено, но равно в
            #     строковом виде пустой строке, то возвращает значение
            #     константы {EMPTY_METHOD}.
            # 4.  В остальных случаях возвращает строковое значение параметра
            #     `:method` в верхнем регистре.
            #
            # @return [String]
            #   результирующее значение
            #
            def method
              return UNSPECIFIED_METHOD unless request_params.key?(:method)
              return NIL_METHOD         if request_params[:method].nil?

              result = request_params[:method].to_s.upcase
              result.tap { return EMPTY_METHOD if result.empty? }
            end

            # Возвращает ассоциативный массив с поправленными параметрами
            # запроса
            #
            # @return [Hash]
            #   результирующий ассоциативный массив
            #
            def censored_params
              Censorship::Filter.process(request_params)
            end

            # Возвращает поправленную строку с телом ответа
            #
            # @param [RestClient::Response] response
            #   ответ
            #
            # @return [String]
            #   результирующая строка
            #
            def adjusted_response_body(response)
              Censorship::Filter.process(repaired_string(response.body))
            end

            # Создаёт запись в журнале событий о запросе и его параметрах
            #
            # @param [Binding] context
            #   контекст
            #
            def log_request(context)
              log_debug(context) { <<-LOG }
                #{method} REQUEST TO `#{url}` WITH PARAMS #{censored_params}
              LOG
            end

            # Создаёт запись в журнале событий о результате выполнения запроса
            #
            # @param [Binding] context
            #   контекст
            #
            # @param [RestClient::Response] response
            #   полученный ответ
            #
            def log_request_response(context, response)
              log_debug(context) { <<-LOG }
                #{method} REQUEST TO `#{url}` GOT RESPONSE
                `#{adjusted_response_body(response)}` WITH #{response.code}
                CODE AND #{Censorship::Filter.process(response.headers)}
                HEADERS
              LOG
            end

            # Создаёт запись в журнале событий об ошибке в процессе выполнения
            # запроса
            #
            # @param [Binding] context
            #   контекст, из которого извлекается информация о вызвавшем методе
            #
            # @param [Exception] e
            #   объект с информацией об ошибке
            #
            def log_request_error(context, e)
              if e.is_a?(RestClient::ExceptionWithResponse)
                log_rest_client_error(context, e)
              else
                log_common_error(context, e)
              end
            end

            # Создаёт запись в журнале событий об ошибке, связанной со статусом
            # ответа (коды 4ХХ, 5ХХ)
            #
            # @param [Binding] context
            #   контекст, из которого извлекается информация о вызвавшем методе
            #
            # @param [RestClient::ExceptionWithResponse] e
            #   объект с информацией об ошибке
            #
            def log_rest_client_error(context, e)
              log_error(context) { <<-LOG }
                #{method} REQUEST TO `#{url}` WITH PARAMS #{censored_params}
                GOT ERROR `#{adjusted_response_body(e.response)}` WITH
                #{e.response.code} CODE
              LOG
            end

            # Создаёт запись в журнале событий об ошибке, не связанной со
            # статусом ответа
            #
            # @param [Binding] context
            #   контекст, из которого извлекается информация о вызвавшем методе
            #
            # @param [Exception] e
            #   объект с информацией об ошибке
            #
            def log_common_error(context, e)
              log_error(context) { <<-LOG }
                #{method} REQUEST TO `#{url}` WITH PARAMS #{censored_params}
                GOT ERROR `#{e.class}` WITH `#{e.message}` MESSAGE
              LOG
            end
          end
        end
      end
    end
  end
end
