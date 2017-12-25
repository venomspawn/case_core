# encoding: utf-8

module MFCCase
  module EventProcessors
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён модулей, подключаемых к классам-потомкам класса
      # `MFCCase::EventProcessors::EventProcessor::CaseEventProcessor`
      #
      module Mixins
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, подключаемый к классам-потомкам класса
        # `MFCCase::EventProcessors::EventProcessor::CaseEventProcessor`,
        # предоставляющий метод `expired?`, который возвращает, необходимо ли
        # возвратить результат заявки в ведомство
        #
        module Expired
          # Возвращает значение атрибута `rejecting_expected_at` заявки
          #
          # @return [NilClass, String]
          #   значение атрибута `rejecting_expected_at` заявки
          #
          def rejecting_expected_at
            case_attributes[:rejecting_expected_at]
          end

          # Регулярное выражение для строки, в начале которой находится дата в
          # формате `ГГГГ-ММ-ДД`
          #
          DATE_STR_REGEXP = /^([0-9]{4})-([0-9]{2})-([0-9]{2}).*/

          # Проверяет, что значение атрибута `rejecting_expected_at` заявки
          # является строкой, в начале которой записана дата в формате
          # `ГГГГ-ММ-ДД`, и возвращает строку с этой датой
          #
          # @return [String]
          #   результирующая строка
          #
          # @raise [RuntimeError]
          #   если значение атрибута `rejecting_expected_at` отсутствует или не
          #   представляет собой строку, в начале которой находится дата в
          #   формате `ГГГГ-ММ-ДД`;
          #
          def rejecting_expected_at_date_str
            match_data = DATE_STR_REGEXP.match(rejecting_expected_at.to_s).to_a
            _, year, month, day = match_data
            Time.new(year, month, day).strftime('%F')
          rescue
            raise Errors::Date::InvalidFormat.new(rejecting_expected_at)
          end

          # Возвращает строку с текущей датой в формате `ГГГГ-ММ-ДД`
          #
          # @return [String]
          #   строка с текущей датой
          #
          def today_str
            now.strftime('%F')
          end

          # Возвращает, необходимо ли возвратить результат заявки в ведомство
          #
          # @return [Boolean]
          #   необходимо ли возвратить результат заявки в ведомство
          #
          def expired?
            rejecting_expected_at_date_str < today_str
          end
        end
      end
    end
  end
end
