require 'spec_helper'

describe EdgeStateMachine::State do
  it "should set from, to, and opts attr readers" do
    opts = {:from => "foo", :to => "bar", :guard => "g"}
    st = EdgeStateMachine::Transition.new(opts)

    st.from.should == opts[:from]
    st.to.should == opts[:to]
    st.options.should == opts
  end

  it "should pass equality check if from and to are the same" do
    opts = {:from => "foo", :to => "bar", :guard => "g"}
    st = EdgeStateMachine::Transition.new(opts)
    obj = EdgeStateMachine::Transition.new(opts)
    obj.should == st
  end

  it "should fail equality check if from are not the same" do
    opts = {:from => "foo", :to => "bar", :guard => "g"}
    st = EdgeStateMachine::Transition.new(opts)
    obj = EdgeStateMachine::Transition.new(opts.merge({:from => "blah"}))
    obj.should_not == st
  end

  it "should fail equality check if to are not the same" do
    opts = {:from => "foo", :to => "bar", :guard => "g"}
    st = EdgeStateMachine::Transition.new(opts)
    obj = EdgeStateMachine::Transition.new(opts.merge({:to => "blah"}))
    obj.should_not == st
  end
end

describe "state transition guard check" do
  it "should return true of there is no guard" do
    opts = {:from => "foo", :to => "bar"}
    st = EdgeStateMachine::Transition.new(opts)
    st.perform(nil).should == true
  end

  it "should call the method on the object if guard is a symbol" do
    opts = {:from => "foo", :to => "bar", :guard => :test_guard}
    st = EdgeStateMachine::Transition.new(opts)

    obj = mock
    obj.should_receive(:test_guard)

    st.perform(obj)
  end

  it "should call the method on the object if guard is a string" do
    opts = {:from => "foo", :to => "bar", :guard => "test_guard"}
    st = EdgeStateMachine::Transition.new(opts)

    obj = mock
    obj.should_receive(:test_guard)

    st.perform(obj)
  end

  it "should call the proc passing the object if the guard is a proc" do
    opts = {:from => "foo", :to => "bar", :guard => Proc.new {|o| o.test_guard}}
    st = EdgeStateMachine::Transition.new(opts)

    obj = mock
    obj.should_receive(:test_guard)

    st.perform(obj)
  end
end