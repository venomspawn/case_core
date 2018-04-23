# frozen_string_literal: true

require_relative 'case_manager/db'
require_relative 'case_manager/extractors/attributes'
require_relative 'case_manager/extractors/cases'

module CaseCore
  module Tasks
    class Transfer
      # Пространство имён классов объектов, оперирующих записями из базы данных
      # `case_manager`
      module CaseManager
      end
    end
  end
end
