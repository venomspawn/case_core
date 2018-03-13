# frozen_string_literal: true

# Файл настройки сервера Puma

# Настройка количества дочерних процессов обработки запросов. Для обработки
# запросов в исходном процессе необходимо выставить значение соответствующей
# переменной окружения равным 0.
puma_workers = ENV['CC_PUMA_WORKERS']
puma_workers = 4 if puma_workers.blank?
workers puma_workers

# Настройка количества минимального и максимального количества потоков
# обработки запросов в каждом процессе обработки запросов
puma_threads_min = ENV['CC_PUMA_THREADS_MIN']
puma_threads_min = 0 if puma_threads_min.blank?
puma_threads_max = ENV['CC_PUMA_THREADS_MAX']
puma_threads_max = 8 if puma_threads_max.blank?
threads puma_threads_min, puma_threads_max

# Загрузка приложения до создания дочерних процессов
preload_app!
