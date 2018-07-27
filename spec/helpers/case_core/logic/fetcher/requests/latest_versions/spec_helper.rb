# frozen_string_literal: true

module CaseCore
  module Logic
    class Fetcher
      module Requests
        class LatestVersions
          # Вспомогательный модуль, подключаемый к тестам класса
          # {CaseCore::Logic::Fetcher::LatestVersionsRequest}
          module SpecHelper
            # Создаёт и возвращает тело файла с информацией о названиях и
            # версиях библиотек
            # @param [Array<Array<(String, String)>>] args
            #   список двухэлементных списков, в которых первый элемент
            #   интерпретируется в качестве названия библиотеки, а второй — в
            #   качестве версии
            # @return [String]
            #   результирующее тело файла
            def create_spec_body(*args)
              spec_data = args.map do |(name, version)|
                [name, ::Gem::Version.new(version)]
              end
              data = Marshal.dump(spec_data)
              Zlib.gzip(data)
            end
          end
        end
      end
    end
  end
end
