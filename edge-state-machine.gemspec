# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "edge-state-machine/version"

Gem::Specification.new do |s|
  s.name        = "edge-state-machine"
  s.version     = EdgeStateMachine::VERSION
  s.authors     = ["Dan Persa"]
  s.email       = ["dan.persa@gmail.com"]
  s.homepage    = "http://github.com/danpersa/edge-state-machine"
  s.summary     = %q{Edge State Machine}
  s.description = %q{Edge State Machine is a complete state machine solution. It offers support for ActiveRecord, Mongoid and MongoMapper for persistence.}

  s.rubyforge_project = "edge-state-machine"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  # specify any dependencies here; for example:
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'mongoid'
  s.add_development_dependency 'mongo_mapper'
  s.add_development_dependency 'bson_ext'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'protected_attributes'
  

  # s.add_runtime_dependency "rest-client"
end
