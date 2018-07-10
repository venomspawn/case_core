# frozen_string_literal: true

# Модуль, предназначенный для проверки загрузки бизнес-логики
module MixedCASE
  # Версия модуля
  VERSION = '0.0.1'

  # Заглушка для вызова при создании тестовой заявки
  def self.on_case_creation(*)
  end

  # Заглушка для вызова тестового метода
  def self.a_method(*)
  end
end
