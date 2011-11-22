require 'spec_helper'
require 'active_record'
require 'active_support/core_ext/module/aliasing'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record/edge-state-machine'
