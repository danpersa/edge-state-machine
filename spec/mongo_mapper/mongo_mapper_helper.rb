require 'spec_helper'
require 'mongo_mapper'


MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "edge_state_machine_mongo_mapper_test"
MongoMapper.database.collections.each { |c| c.drop_indexes }

require 'mongo_mapper/samples/traffic_light'
require 'mongo_mapper/samples/order'
require 'mongo_mapper/samples/double_machine'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mongo_mapper/edge-state-machine'


