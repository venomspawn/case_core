# frozen_string_literal: true

require "#{$lib}/settings/configurable"

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Модуль интеграции с сервисом Consul, представляющий собой обёртку над
  # библиотекой `diplomat`
  #
  module Consul
    extend Settings::Configurable

    settings_names :tag

    # Возвращает информацию о сервисе
    #
    # @param [String] name
    #   название сервиса
    #
    # @return [OpenStruct]
    #   информация о сервисе
    #
    def self.service(name)
      args = [name, :first]
      args << { tag: settings.tag } unless settings.tag.blank?
      Diplomat::Service.get(*args)
    end
  end
end
