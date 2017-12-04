# encoding: utf-8

require_relative 'publisher'

module CaseCore
  module API
    module STOMP
      class Controller
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Класс, предоставляющий доступ к отображению произвольных объектов в
        # объекты, публикующие сообщения STOMP
        #
        class Publishers
          # Инициализирует объект класса
          #
          def initialize
            @publishers = {}
            @mutex = Thread::Mutex.new
          end

          # Возвращает объект, публикующий сообщения STOMP, сопоставленный
          # предоставленному объекту. Если объект не найден, то он создаётся.
          #
          # @return [CaseCore::API::STOMP::Publisher]
          #   результирующий объект, публикующий сообщения STOMP
          #
          def [](obj)
            publishers[obj.object_id] || mutex.synchronize do
              publishers[obj.object_id] ||= create_publisher(obj)
            end
          end

          private

          # Ассоциативный массив, в котором идентификаторам объектов
          # сопоставлены объекты, публикующие сообщения STOMP
          #
          # @return [Hash{Integer => CaseCore::API::STOMP::Publisher]
          #   ассоциативный массив, в котором идентификаторам объектов
          #   сопоставлены объекты, публикующие сообщения STOMP
          #
          attr_reader :publishers

          # Объект, позволяющий синхронизировать создание объектов, публикующих
          # сообщения STOMP, между различными потоками
          #
          # @return [Thread::Mutex]
          #   объект, позволяющий проводить синхронизацию
          #
          attr_reader :mutex

          # Создаёт и возвращает новый объект, публикующий сообщения STOMP, а
          # также устанавливает, чтобы идентификатор аргумента был удалён из
          # ключей ассоциативного массива {publishers} при обработке аргумента
          # сборщиком мусора
          #
          # @param [Object] obj
          #   объект, чьему идентификатору сопоставляется созданный объект,
          #   публикующий сообщения STOMP
          #
          def create_publisher(obj)
            ObjectSpace.define_finalizer(obj, &publishers.method(:delete))
            Publisher.new
          end
        end
      end
    end
  end
end
