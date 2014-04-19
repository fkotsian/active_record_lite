require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    objects= results.map do |object_params|
      self.new(object_params)
    end
  end
end

class SQLObject < MassObject
  def self.columns
    table_cols = DBConnection.execute2("SELECT * FROM #{table_name}").first.map(&:to_sym)

    table_cols.each do |attribute_name|
      define_method("#{attribute_name}")  { self.attributes[attribute_name.to_sym] }
      define_method("#{attribute_name}=") { |arg| self.attributes[attribute_name.to_sym] = arg }
    end
    table_cols
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.pluralize.underscore
  end

  def self.all
    # this is Class.all (all obj of that class)
    object_hashes = DBConnection.execute(<<-SQL)
      SELECT
        "#{self.table_name}".*
      FROM
        "#{self.table_name}"
      SQL
    self.parse_all(object_hashes)
  end

  def self.find(id)
    obj_data = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
      LIMIT 1
    SQL
    # p "Returned data from _find is: #{obj_data}"
    self.new(obj_data.first)
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = self.attributes.keys.select { |col| !col.nil? }.join(", ")
    question_marks = (["?"] * (self.attribute_values
      .select {|col| !col.nil? }.length ) ).join(", ")

    DBConnection.execute(<<-SQL, *self.attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL

    # set ID following insertion of rest of values
    self.attributes[:id] = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|

      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute: #{attr_name}"
      end

      self.attributes[attr_name.to_sym] = value
    end
  end

  def save
    case self.id.nil?
    when true
      self.insert
    when false
      self.update
    end
  end

  def update
    set_line = self.attributes.map { |attr_name, value| "#{attr_name} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *self.attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def attribute_values
    self.attributes.map { |attr, value| self.send("#{attr.to_sym}") unless value.nil? }.compact
  end
end

class Cat < SQLObject

end