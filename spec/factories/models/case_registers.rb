# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей связей между заявками и реестрами передаваемой
# корреспонденции
#

FactoryGirl.define do
  factory :case_register, class: CaseCore::Models::CaseRegister do
    association :case
    association :register
  end
end
