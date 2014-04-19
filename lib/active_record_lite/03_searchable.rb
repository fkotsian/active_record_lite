require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
    DBConnection.execute(<<-SQL, params.values)
    SELECT
      *
    FROM
      self.class.table_name
    WHERE
      where_line
    SQL
  end
end

class SQLObject
  include Searchable
end
