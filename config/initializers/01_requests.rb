# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки REST-запросов ко внешним ресурсам
#

Dir["#{$lib}/requests/**/*.rb"].each(&method(:require))
