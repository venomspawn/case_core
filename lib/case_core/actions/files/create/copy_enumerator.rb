# frozen_string_literal: true

module CaseCore
  module Actions
    module Files
      class Create
        # Класс специальных перечислителей, используемых для передачи данных
        # при выполнении SQL-команды `COPY`
        class CopyEnumerator
          # Инициализирует объект класса
          # @param [Array] thingies
          #   список строк, целых положительных чисел, потоков, времени
          def initialize(*thingies)
            @thingies = thingies
            @enum = Enumerator.new(&method(:push_thingies))
          end

          # Перечисляет данные, вызывая предоставленный блок
          # @yieldparam [String] data
          #   данные
          def each
            enum.each { |s| yield s }
          end

          private

          # Список строк, целых положительных чисел, потоков, времени
          # @return [Array]
          #   список строк, целых положительных чисел, потоков, времени
          attr_reader :thingies

          # Перечислитель строк
          # @return [Enumerator]
          #   перечислитель строк
          attr_reader :enum

          # Посылает данные в предоставленный объект
          # @param [Enumerator::Yielder] yielder
          #   объект, принимающий данные
          def push_thingies(yielder)
            push_proc = yielder.method(:<<).to_proc
            thingies.each_with_object(push_proc, &method(:push_thingie))
          end

          # Максимальное количество байт, одновременно передаваемых в `COPY` из
          # потока
          CHUNK_SIZE = 32_768

          # Использует предоставленную процедуру, вызывая её в зависимости от
          # типа аргумент с различными аргументами
          # @param [Object] thingie
          #   аргумент
          # @param [Proc] push_proc
          #   предоставленная процедура
          def push_thingie(thingie, push_proc)
            case thingie
            # Передача всех строк массива
            when Array then thingie.each(&push_proc)
            # Передача строки
            when String then push_proc[thingie]
            # Передача четырёхбайтной строки с представлением целого числа
            when Integer then push_proc[int_byte_str(thingie)]
            # Передача восьмибайтной строки с представлением времени
            when Time then push_proc[time_byte_str(thingie)]
            # Передача потока
            else push_stream(thingie, push_proc)
            end
          end

          # Передаёт части потока с помощью предоставленной процедуры, если
          # аргумент предоставляет интерфейс потока
          # @param [Object] thingie
          #   аргумент
          # @param [Proc] push_proc
          #   предоставленная процедура
          def push_stream(thingie, push_proc)
            return unless thingie.respond_to?(:each)
            # Перемотка потока в начало, если он поддерживает такую операцию
            thingie.rewind if thingie.respond_to?(:rewind)
            # Передача частей потока
            thingie.each(CHUNK_SIZE, &push_proc)
          end

          # Заготовка для четырёхбайтной строки с представлением целого числа
          INT_BYTE_STR = "\x00\x00\x00\x00".b.freeze

          # Возвращает четырёхбайтную строку с представлением целого числа
          # (слева направо от старших байт к младшим)
          # @param [Integer] int
          #   предоставленное число
          # @return [String]
          #   результирующая строка
          def int_byte_str(int)
            INT_BYTE_STR.dup.tap do |str|
              str.setbyte(0, (int >> 24) & 0xFF)
              str.setbyte(1, (int >> 16) & 0xFF)
              str.setbyte(2, (int >> 8) & 0xFF)
              str.setbyte(3, int & 0xFF)
            end
          end

          # Заготовка для восьмибайтной строки с представлением времени
          TIME_BYTE_STR = "\x00\x00\x00\x00\x00\x00\x00\x00".b.freeze

          # Разница в количестве микросекунд, вызванная тем, что PostgreSQL
          # отсчитывает время не от Epoch (1970-01-01), а от 2000-01-01
          POSTGRESQL_SHIFT = 946_684_800_000_000

          # Разница в количестве микросекунд, вызванная временной зоной
          TIMEZONE_SHIFT = 60 * 60 * 3 * 1_000_000

          # Возвращает восьмибайтную строку с представлением времени в формате
          # PostgreSQL
          # @param [Time] time
          #   объект с информацией о времени
          # @return [String]
          #   результирующая строка
          def time_byte_str(time)
            usec = time.tv_sec * 1_000_000 +
                   time.tv_usec -
                   POSTGRESQL_SHIFT +
                   TIMEZONE_SHIFT
            TIME_BYTE_STR.dup.tap do |str|
              8.times do |i|
                str.setbyte(7 - i, usec & 0xFF)
                usec >>= 8
              end
            end
          end
        end
      end
    end
  end
end
