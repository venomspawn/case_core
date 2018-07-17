# frozen_string_literal: true

require 'securerandom'

module CaseCore
  module Actions
    module Files
      # Класс действий, создающих запись файла
      class Create
        require_relative 'create/copy_enumerator'

        # Инициализирует объект класса
        # @param [#read, #to_s] content
        #   содержимое, которое может быть представлено потоком или извлечено с
        #   помощью `#to_s`
        def initialize(content)
          @content = content
        end

        # Шестнадцатеричное представление с ведущим нулём
        BYTE = '%02x'

        # Шестнадцатеричное представление двух байт
        BYTE_2 = BYTE * 2

        # Шестнадцатеричное представление четырёх байт
        BYTE_4 = BYTE * 4

        # Шестнадцатеричное представление шести байт
        BYTE_6 = BYTE * 6

        # Строковое представление UUID
        UUID_FORMAT = [BYTE_4, BYTE_2, BYTE_2, BYTE_2, BYTE_6].join('-').freeze

        # Создаёт запись файла с предоставленным содержимым и возвращает
        # ассоциативный массив с информацией о записи
        # @return [Hash]
        #   результирующий ассоциативный массив
        def create
          Sequel::Model.db.copy_into(:files, format: :binary, data: data)
          { id: format(UUID_FORMAT, *uuid.bytes) }
        end

        private

        # Содержимое, которое может быть представлено потоком или извлечено с
        # помощью `#to_s`
        # @return [#read, #to_s]
        #   содержимое, которое может быть представлено потоком или извлечено с
        #   помощью `#to_s`
        attr_reader :content

        # Возвращает строку из 16 байт с UUID v4
        # @return [String]
        #   результирующая строка
        def uuid
          @uuid ||= SecureRandom.random_bytes.tap do |str|
            byte = str.getbyte(6)
            # Установка версии (0100b) в старших битах 6-го байта
            str.setbyte(6, (byte & 0x0F) | 0x40)

            byte = str.getbyte(9)
            # Установка дополнительных бит (10b) в старших битах 9-го байта
            str.setbyte(9, (byte & 0x3F) | 0x80)
          end
        end

        # Метка начала строки с данными для команды `COPY` в двоичном формате
        SIGNATURE = "PGCOPY\n\xFF\r\n\x00".b.freeze

        # Поле флагов в строке с данными для команды `COPY` в двоичном формате
        FLAGS = "\x00\x00\x00\x00".b.freeze

        # Поле расширения заголовка в строке с данными для команды `COPY` в
        # двоичном формате
        EXT = "\x00\x00\x00\x00".b.freeze

        # Поле с количеством импортируемых полей в строке с данными для команды
        # `COPY` в двоичном формате
        COUNT = "\x00\x03".b.freeze

        # Поле с количеством байт в импортируемом значении поля `uuid` в
        # строке с данными для команды `COPY` в двоичном формате
        LENGTH_UUID = "\x00\x00\x00\x10".b.freeze

        # Список строк, передаваемых до значения поля `uuid`
        PREFIX = [SIGNATURE, FLAGS, EXT, COUNT, LENGTH_UUID]

        # Поле с количеством байт в импортируемом значении поля `created_at` в
        # строке с данными для команды `COPY` в двоичном формате
        LENGTH_CREATED_AT = "\x00\x00\x00\x08".b.freeze

        # Метка окончания результата выполнения команды `COPY` в двоичном
        # формате
        TRAILER = "\xFF\xFF".b.freeze

        # Возвращает объект с методом `each`
        # @return [#each]
        #   результирующий объект
        def data
          args = [
            PREFIX,
            uuid,
            content.size,
            content.respond_to?(:read) ? content : content.to_s,
            LENGTH_CREATED_AT,
            Time.now,
            TRAILER
          ]
          CopyEnumerator.new(*args)
        end
      end
    end
  end
end
