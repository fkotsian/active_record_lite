require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || name.to_s.downcase.singularize.concat("_id").to_sym
    @primary_key = options[:primary_key] || :id
    @class_name =  options[:class_name] || name.to_s.gsub("_", "").singularize.camelcase
    ""
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || ( self_class_name.downcase.singularize.concat("_id").to_sym )
    @primary_key = options[:primary_key] || :id
    @class_name =  options[:class_name] || name.to_s.gsub("_", "").singularize.camelcase
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    belongs_to_opts = BelongsToOptions.new(name, options)
    self.assoc_options[name] = belongs_to_opts

    define_method name do
      f_key = belongs_to_opts.foreign_key
      p_key = belongs_to_opts.primary_key
      p "Foreign key is: #{f_key}"
      m_class = belongs_to_opts.model_class
      m_class.where( p_key => self.send(f_key) ).first
    end
  end

  def has_many(name, options = {})
    belongs_to_opts = HasManyOptions.new(name, self.to_s, options)

    define_method name do
      f_key = belongs_to_opts.foreign_key
      p_key = belongs_to_opts.primary_key
      p "Foreign key is: #{f_key}"
      m_class = belongs_to_opts.model_class
      m_class.where( f_key => self.send(p_key) )
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
