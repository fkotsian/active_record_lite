require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")

    obj_data = DBConnection.execute(<<-SQL, *params.values)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      #{where_line}
    SQL

    parse_all(obj_data)
  end
end

class SQLObject
  extend Searchable
end
