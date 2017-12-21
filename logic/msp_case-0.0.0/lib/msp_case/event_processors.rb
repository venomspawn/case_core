# encoding: utf-8

Dir["#{__dir__}/event_processors/*.rb"].each(&method(:load))

module MSPCase
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён классов обработчиков событий
  #
  module EventProcessors
  end
end
