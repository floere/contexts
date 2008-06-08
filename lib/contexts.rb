# Contains all the necessary stuff for contexts.
#
# Loading of context data is done in the following methods:
# load_context_data_for_<category>_<type>
#
module Contexts
  
  def self.included(base)
    base.class_eval do
      base.extend(ClassMethods)
    end
  end
  
  module ClassMethods
    
    # Creates code that is used for determining which context type for which category is used.
    #
    # Either
    # context :title, :profile # always uses the profile type for the title context
    # or
    # context :title do
    #   do some determining stuff
    #   return :determined_type
    # end
    # or
    # context :title, :profile, [:some_action, :some_other_action] => :search, :another_action => :empty
    #
    def context(category, default = nil, *specifics, &block)
      raise 'Context needs a category.' unless category
      if block_given?
        define_method "determine_context_type_for_#{category}", &block
      else
        raise 'Context without a block needs at least a default type. Use context :navigation, :profile' unless default
        if specifics.empty?
          define_method "determine_context_type_for_#{category}" do
            default
          end
        else
          specifics_hash = {}
          specifics.first.each do |actions, type|
            [*actions].each do |action|
              specifics_hash[action.to_s] = type
            end
          end
          define_method "determine_context_type_for_#{category}" do
            type = params && specifics_hash[params[:action]]
            type ? type : default
          end
        end
      end
    end
    
    # Creates code that is used to load context data for a specific category type.
    # load_context_data_for_<category>_<type>
    #
    def load_context(category, type, caching_options = {}, &block)
      type_method_name_part = Context.methodify(type)
      cache_duration = caching_options[:cache]
      if cache_duration
        define_method "context_cache_duration_for_#{category}_#{type_method_name_part}" do
          cache_duration
        end
      end
      define_method "load_context_data_for_#{category}_#{type_method_name_part}" do |view_instance|
        view_instance.instance_eval(&block)
      end
    end
    
  end
  
end
