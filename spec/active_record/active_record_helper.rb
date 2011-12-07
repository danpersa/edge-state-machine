require 'spec_helper'
require 'active_record'
require 'active_support/core_ext/module/aliasing'
require 'active_record/migrations/create_orders'
require 'active_record/migrations/create_traffic_lights'
require 'active_record/migrations/create_double_machine'
require 'active_record/samples/traffic_light'
require 'active_record/samples/order'
require 'active_record/samples/double_machine'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record/edge-state-machine'
