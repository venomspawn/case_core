# frozen_string_literal: true

require 'stringio'

module CaseCore
  need 'actions/base/action'

  module Actions
    module Files
      # Класс действий, возвращающих содержимое файлов
      class Show < Base::Action
        require_relative 'show/errors'
        require_relative 'show/params_schema'

        # Параметры операции `COPY`
        COPY_PARAMS = { format: :binary }.freeze

        # Возвращает содержимое файла
        # @return [String]
        #   содержимое файла
        # @raise [Sequel::NoMatchingRow]
        #   если запись файла не найдена
        def show
          content = Sequel::Model.db.copy_table(copy_dataset, COPY_PARAMS)
          check_content!(content)
          extract_content(content)
        end

        private

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        # @return [Object]
        #   результирующее значение
        def id
          params[:id]
        end

        # Запрос Sequel на извлечение содержимого файла
        COPY_DATASET = Models::File.select(:content).limit(1)

        # Возвращает запрос Sequel на извлечение содержимого файла
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        def copy_dataset
          COPY_DATASET.where(id: id)
        end

        # Метка начала результата выполнения команды `COPY` в двоичном формате
        SIGNATURE = "PGCOPY\n\xFF\r\n\x00".b.freeze

        # Поле флагов в результате выполнения команды `COPY` в двоичном формате
        FLAGS = "\x00\x00\x00\x00".b.freeze

        # Поле расширения заголовка в результате выполнения команды `COPY` в
        # двоичном формате
        EXT = "\x00\x00\x00\x00".b.freeze

        # Метка окончания результата выполнения команды `COPY` в двоичном
        # формате
        TRAILER = "\xFF\xFF".b.freeze

        # Длина результата запроса на содержимое файла в случае, если запись
        # файла не найдена. Позволяет однозначно определить, найдена ли запись,
        # так как длина результата в случае обнаружения записи строго больше.
        NO_MATCHING_ROW_SIZE =
          SIGNATURE.size + FLAGS.size + EXT.size + TRAILER.size

        # Проверяет по результату запроса, была ли найдена запись файла
        # @param [String] content
        #   результат запроса
        # @raise [Sequel::NoMatchingRow]
        #   если запись файла не найдена
        def check_content!(content)
          return if content.size > NO_MATCHING_ROW_SIZE
          raise Errors::File::NotFound, id
        end

        # Поле с количеством возвращаемых записей в результате выполнения
        # команды `COPY` в двоичном формате
        COUNT = "\x00\x01".b.freeze

        # Поле с количеством байт в извлекаемом значении поля `content` в
        # результате выполнения команды `COPY` в двоичном формате
        LENGTH = "\x00\x00\x00\x00"

        # Количество байт, идущих перед содержимым
        CONTENT_PREFIX_SIZE =
          SIGNATURE.size +
          FLAGS.size +
          EXT.size +
          COUNT.size +
          LENGTH.size

        # Возвращает строку, полученную из строки с результатом выполнения
        # команды `COPY` в двоичном формате. Использует так называемую
        # "Zero-Copy" технику.
        # @param [String] content
        #   исходная строка с результатом выполнения команды `COPY` в двоичном
        #   формате
        def extract_content(content)
          truncate_content(content)
          content[CONTENT_PREFIX_SIZE, content.size - CONTENT_PREFIX_SIZE]
        end

        # Удаляет метку окончания результата выполнения команды `COPY` в
        # двочином формате
        # @param [String] content
        #   исходная строка с результатом выполнения команды `COPY` в двоичном
        #   формате
        def truncate_content(content)
          # Среди методов объектов класса String нет такого, с помощью которого
          # можно было бы убрать символы в конце строки без её копирования.
          # Такой метод `truncate` тем не менее присутствует в экземпляре
          # класса `StringIO`.
          io = StringIO.new(content)
          # Удаление метки окончания результата выполнения команды `COPY` в
          # двоичном формате
          io.truncate(content.size - TRAILER.size)
        end
      end
    end
  end
end
