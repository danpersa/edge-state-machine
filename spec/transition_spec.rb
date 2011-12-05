require 'spec_helper'

describe EdgeStateMachine::Transition do
  it "should set from, to, and opts attr readers" do
    opts = {:from => "foo", :to => "bar", :guard => "g"}
    st = EdgeStateMachine::Transition.new(opts)

    st.from.should == [opts[:from]].flatten
    st.to.should == [opts[:to]].flatten
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

  describe "state transition guard check" do
    it "should return true of there is no guard" do
      opts = {:from => "foo", :to => "bar"}
      st = EdgeStateMachine::Transition.new(opts)
      st.possible?(nil).should == true
    end

    it "should call the method on the object if guard is a symbol" do
      opts = {:from => "foo", :to => "bar", :guard => :test_guard}
      st = EdgeStateMachine::Transition.new(opts)

      obj = mock
      obj.should_receive(:test_guard)

      st.find_next_state(obj)
    end

    it "should call the method on the object if guard is a string" do
      opts = {:from => "foo", :to => "bar", :guard => "test_guard"}
      st = EdgeStateMachine::Transition.new(opts)

      obj = mock
      obj.should_receive(:test_guard)

      st.find_next_state(obj)
    end

    it "should call the proc passing the object if the guard is a proc" do
      opts = {:from => "foo", :to => "bar", :guard => Proc.new {|o| o.test_guard}}
      st = EdgeStateMachine::Transition.new(opts)

      obj = mock
      obj.should_receive(:test_guard)

      st.find_next_state(obj)
    end
  end

  describe "on transition execution" do
    it "should call the method on the object if on_transition is a symbol" do
      opts = {:from => "foo", :to => "bar", :on_transition => :test_on_transition}
      st = EdgeStateMachine::Transition.new(opts)
      obj = mock
      obj.should_receive(:test_on_transition)
      st.execute(obj)
    end

    it "should call the method on the object if on_transition is a string" do
      opts = {:from => 'foo', :to => 'bar', :on_transition => 'test_on_transition'}
      st = EdgeStateMachine::Transition.new(opts)
      obj = mock
      obj.should_receive(:test_on_transition)
      st.execute(obj)
    end

    it "should call the method on the object if on_transition is a proc" do
      opts = {:from => 'foo', :to => 'bar', :on_transition => Proc.new {|o| o.test_on_transition}}
      st = EdgeStateMachine::Transition.new(opts)
      obj = mock
      obj.should_receive(:test_on_transition)
      st.execute(obj)
    end

    it "should call all the methods/procs if on_transition is an array" do
      opts = { :from => 'foo',
                :to => 'bar',
                :on_transition => [Proc.new {|o| o.test_on_transition}, :test_on_transition, 'test_on_transition']}
      st = EdgeStateMachine::Transition.new(opts)
      obj = mock
      obj.should_receive(:test_on_transition).exactly(3).times
      st.execute(obj)
    end
  end
end



