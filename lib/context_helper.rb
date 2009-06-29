module ContextHelper
  
  def render_context category, type = nil
    return unless category
    context = Context.new @controller, self, category, type
    context.render
  end
  
end