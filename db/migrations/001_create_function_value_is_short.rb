# frozen_string_literal: true

# Создание SQL-функции `value_is_short`

Sequel.migration do
  up do
    opts = {
      args:     [%w[text value]],
      behavior: :immutable,
      language: :plpgsql,
      replace:  true,
      returns:  :boolean
    }
    create_function(:value_is_short, <<-SQL.squish, opts)
      BEGIN
        RETURN char_length(value) < 200;
      END;
    SQL
  end

  down do
    drop_function(:value_is_short, if_exists: true)
  end
end
