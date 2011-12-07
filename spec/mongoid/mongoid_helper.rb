require 'spec_helper'
require 'mongoid'
require 'mongoid/samples/traffic_light'
require 'mongoid/samples/order'
require 'mongoid/samples/double_machine'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mongoid/edge-state-machine'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('edge_state_machine_test')
  config.allow_dynamic_fields = false
end