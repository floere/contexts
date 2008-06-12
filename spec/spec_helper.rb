require 'spec'
require 'flexmock'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'active_support'
require 'action_controller'

# Set up flexmock as mock framework
Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

require File.join(File.dirname(__FILE__), '../init')

# Used to test private methods.
#
# The idea is to replace instance.send :private_method.
# Now it is rather like:
# We have the scenario we are in the given instance.
#
def in_the(instance, &block)
  instance.instance_eval(&block)
end