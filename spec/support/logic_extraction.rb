# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки проверки на то, распаковалась ли загруженная библиотека с
# бизнес-логикой или нет
#

RSpec::Matchers.define :extract_logic_file do |filepath|
  match do |object|
    object.call
    File.exists?(filepath)
  end

  supports_block_expectations
end
