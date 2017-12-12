# encoding: utf-8

module CaseCore
  module Logic
    class Fetcher
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Вспомогательный модуль, подключаемый к тестам класса
      # {CaseCore::Logic::Fetcher::LatestVersionRequest}
      #
      module LatestVersionRequestSpecHelper
        def create_spec_body(*args)
          spec_data = args.map do |(name, version)|
            [name, Gem::Version.new(version)]
          end
          Marshal.dump(spec_data)
        end
      end
    end
  end
end