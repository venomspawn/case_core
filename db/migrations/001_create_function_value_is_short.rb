# frozen_string_literal: true

# Создание SQL-функции `short_value`

Sequel.migration do
  up do
    opts = {
      args:     [%w[text value]],
      behavior: :immutable,
      language: :plpgsql,
      replace:  true,
      returns:  :text
    }
    create_function(:short_value, <<-SQL, opts)
      BEGIN
        RETURN substring(value from 1 for 200);
      END;
    SQL
  end

  down do
    drop_function(:short_value, if_exists: true)
  end
end
