# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Поддержка Sequel в FactoryGirl
#

FactoryGirl.define do
  to_create(&:save)
end
