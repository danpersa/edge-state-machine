require 'spec_helper'
require 'non_persistent/samples/dice'
require 'non_persistent/samples/user'
require 'non_persistent/samples/microwave'
require 'non_persistent/samples/double_machine'
require 'non_persistent/samples/on_off_switch'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'edge-state-machine'