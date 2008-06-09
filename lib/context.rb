class Context
  
  attr_reader :controller, :view, :category, :type, :bucket, :type_method_name, :view_instance_variables
  
  # Helper method to change type template locations from e.g.
  # path/to/some_template to path__to__some_template
  # making it useable for method names.
  #
  def self.methodify(type)
    type.to_s.gsub('/','__')
  end
  
  def initialize(controller, view, category, type = nil)
    @controller, @view, @category = controller, view, category
    
    # determine context type from controller if the user has not specifically given a type
    @type = type || controller.send("determine_context_type_for_#{category}")
    
    #
    @type_method_name = self.class.methodify(@type)
    
    # save the view instance variables for view initialization
    @view_instance_variables = view.instance_variables.inject({}) do |vars, var|
      vars[var] = view.instance_variable_get(var)
      vars
    end
    
    # instantiate a data bucket we expose to the controller
    @bucket = Object.new
    
    # fill the bucket with view instance variables
    @view_instance_variables.each do |k,v|
      @bucket.instance_variable_set(k, v)
    end
  end
  
  # Does the actual rendering, caching, and view exposing to the controller.
  #
  def render
    fragment = cached_fragment if caching_enabled?
    return fragment if fragment
    
    view = view_instance #_from view_class
    load_data_from_controller_into bucket
    load_data_from_bucket_into view
    
    content = render_content_for view
    cache content if caching_enabled?
    content
  end
  
  # Checks if caching is enabled for this controller, category, and type.
  #
  def caching_enabled?
    caching_enabled_method_name = "context_cache_duration_for_#{category}_#{type_method_name}".to_sym
    controller.respond_to?(caching_enabled_method_name)
  end
  
  # Caches the given fragment for this context.
  #
  def cache(content)
    controller.write_fragment cache_key, content, :ttl => cache_duration
  end
  
  private
    
    def cache_duration
      caching_enabled_method_name = "context_cache_duration_for_#{category}_#{type_method_name}".to_sym
      controller.send(caching_enabled_method_name)
    end
  
    # Renders the template for the context with the given view instance.
    #
    def render_content_for(view_instance)
      view_instance.render_file(File.join(RAILS_ROOT, 'app/views', 'contexts', category.to_s, "#{type}.haml"), false)
    end
    
    # Calls the load context data method on the controller to fill the bucket with data.
    #
    def load_data_from_controller_into(bucket)
      load_context_data_method_name = "load_context_data_for_#{category}_#{type_method_name}"
      # expose the context view instance to the controller
      controller.send load_context_data_method_name, bucket if controller.respond_to? load_context_data_method_name.to_sym
    end
    
    # Load the data from the bucket into the view instance.
    #
    def load_data_from_bucket_into(view_instance)
      bucket.instance_variables.each do |var|
        view_instance.instance_variable_set(var, bucket.instance_variable_get(var))
      end
    end
    
    # Retrieves the cached fragment for this context.
    #
    def cached_fragment
      controller.read_fragment cache_key
    end
    
    # Creates a new view instance from the given view class.
    #
    def view_instance #_from(view_class)
      controller.response.template
      # view_class.new(controller.template_root, bucket.instance_variables)
    end
    
    # Gets the view class from the controller, adding caching capabilities.
    #
    # def view_class
    #   view_klass = controller.response.template.class # TODO
    #   view_klass.send :include, CacheKeyFactory
    #   view_klass
    # end
    
    # Cache key for contexts.
    #
    def cache_key
      "context/#{category}/#{type}"
    end
end