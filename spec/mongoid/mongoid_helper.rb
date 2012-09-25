require 'spec_helper'
require 'mongoid'
require 'mongoid/samples/traffic_light'
require 'mongoid/samples/order'
require 'mongoid/samples/double_machine'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mongoid/edge-state-machine'

ENV['RACK_ENV'] = 'test'
Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml')