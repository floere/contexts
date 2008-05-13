require 'context'
require 'contexts'
require 'context_helper'
ActionController::Base.send :include, Contexts
ActionView::Base.send :include, ContextHelper