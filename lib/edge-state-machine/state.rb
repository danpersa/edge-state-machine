module EdgeStateMachine
  class State
    attr_reader :name, :options

    def initialize(name, &block)
      @name = name
      @options = Hash.new
      instance_eval(&block) if block_given?
    end

    def enter(method = nil, &block)
      @options[:enter] = method.nil? ? block : method
    end

    def exit(method = nil, &block)
      @options[:exit] = method.nil? ? block : method
    end

    def execute_action(action, base)
      action = @options[action.to_sym]
      case action
      when Symbol, String
        base.send(action)
      when Proc
        action.call(base)
      end
    end

    def use_display_name(display_name)
      @display_name = display_name
    end

    def display_name
      @display_name ||= name.to_s.gsub(/_/, ' ').capitalize
    end

    def ==(st)
      if st.is_a? Symbol
        name == st
      elsif st.is_a? String
        name == st
      else
        name == st.name
      end
    end
  end
end
