# ScopedSearch, Copyright (c) 2010 Novagile.
# Written by Nicolas Blanco.
# Licensed under MIT license.
#
class ScopedSearch
  class Base
    extend ActiveModel::Naming
    
    SINGLE_SCOPES_VALUES = %w(true 1)
    
    attr_reader :attributes, :model_class, :attributes_merged
    
    def initialize(klass, options)
      @model_class       = klass
      @attributes        = options
      @attributes_merged = @attributes.reverse_merge(klass.scopes.keys.inject({}) { |m,o| m[o] = nil; m; })

      @attributes_merged.each do |attribute, value|
        class_eval <<-RUBY
          def #{attribute}
            @attributes[:#{attribute}]
          end
          
          def #{attribute}=(val)
            @attributes[:#{attribute}] = val
          end
        RUBY
      end
    end
    
    def build_relation
      return model_class if attributes.empty?
      attributes.reject { |k,v| v.blank? }.inject(model_class) do |s, k|
        if model_class.scopes.keys.include?(k.first.to_sym)
          k.size == 2 && SINGLE_SCOPES_VALUES.include?(k.last.to_s) ? s.send(k.first) : s.send(*k)
        else
          s
        end
      end
    end
    
    def to_key; nil; end
    
    def method_missing(method_name, *args)
      build_relation.send(method_name, *args)
    end
  end
  
  module Helpers
    extend ActiveSupport::Concern
    
    def form_for(record, *args, &block)
      if record.is_a?(ScopedSearch::Base)
        options = args.extract_options!
        options.symbolize_keys!
        
        default_model_route = (polymorphic_path(record.model_class) rescue nil)
        
        options.reverse_merge!({ :url => default_model_route, :as => :search })
        raise "You have to manually specify :url in your form_for options..." unless options[:url].present?
        
        options[:html] ||= {}
        options[:html].reverse_merge!({ :method => :get })
        args << options
      end

      super(record, *args, &block)
    end
    
    # TODO :
    # refactor this ?
    def order_for_scoped_search(column, search_param = :search)
      search_order = params[search_param].present? && params[search_param]["ascend_by_#{column}"].present? ? { "descend_by_#{column}" => true } : { "ascend_by_#{column}" => true }
      
      params[search_param] ||= {}
      search_without_order = params[search_param].clone
      search_without_order.delete_if { |k,v| k.to_s.starts_with?("ascend_by") || k.to_s.starts_with?("descend_by") }
      
      params.merge(search_param => search_without_order.merge(search_order))
    end
  end
  
  module Model
    extend ActiveSupport::Concern
    
    module ClassMethods
      def scoped_search(options={})
        ScopedSearch::Base.new(self, options.present? ? options : {})
      end
      
      def scoped_order(*columns_names)
        if defined?(Mongoid) && self.include?(Mongoid::Document)
          columns_names.each do |column_name|
            scope :"ascend_by_#{column_name}",  order_by([column_name.to_sym, :desc])
            scope :"descend_by_#{column_name}", order_by([column_name.to_sym, :asc])
          end
        else
          columns_names.each do |column_name|
            scope :"ascend_by_#{column_name}",  order("#{column_name} asc")
            scope :"descend_by_#{column_name}", order("#{column_name} desc")
          end
        end
      end
    end
  end
end

