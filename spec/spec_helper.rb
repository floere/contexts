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