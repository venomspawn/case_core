# encoding: utf-8

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Модуль интеграции с сервисом Consul, представляющий собой обёртку над
  # библиотекой `diplomat`
  #
  module Consul
    # Возвращает информацию о сервисе
    #
    # @param [String] name
    #   название сервиса
    #
    # @return [OpenStruct]
    #   информация о сервисе
    #
    def self.service(name)
      Diplomat::Service.get(name)
    end
  end
end
