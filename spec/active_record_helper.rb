require 'spec_helper'
require 'active_record'
require 'active_support/core_ext/module/aliasing'
require 'migrations/create_orders'
require 'migrations/create_traffic_lights'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record/edge-state-machine'
