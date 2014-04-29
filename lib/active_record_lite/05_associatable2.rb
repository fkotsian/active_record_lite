require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method name do
      through_options = self.class.assoc_options[through_name]
      # source_name = through_options.model_class
      source_options = through_options.model_class.assoc_options[source_name]
      p through_options
      p source_options

      through_f_key = through_options.foreign_key
      through_p_key = through_options.primary_key
      through_m_class = through_options.class_name.constantize.table_name

      source_f_key = source_options.foreign_key
      source_p_key = source_options.primary_key
      source_m_class = source_options.class_name.constantize.table_name

      # perhaps self.send "through_f_key"
      object_f_key = self."#{through_f_key}"
      p object_f_key

      assoc_data = DBConnection.execute(<<-SQL, object_f_key)
      SELECT
      #{source_m_class}.*
      FROM
      #{through_m_class}
      JOIN
      #{source_m_class}
      ON
      #{through_m_class}.#{source_f_key} = #{source_m_class}.#{source_p_key}
      WHERE
      #{through_m_class}.#{through_p_key} = ?
      SQL

      self.class.parse_all(assoc_data)
    end
  end

end
