module ContextHelper
  
  # Renders a context into the view.
  # 
  # 2 ways:
  #   
  #   1. render_context :category
  #      Asks the controller which specific type to use.
  #
  #   2. render_context :category, :specific_type
  #      Renders a specific type of this context category without asking the controller.
  #
  def render_context category, type = nil
    return unless category
    context = Context.new @controller, self, category, type
    context.render
  end
  
end