module YNM
  class Context
    attr_reader :stack, :variables

    def initialize(base = nil)
      @variables = base.nil? ? {} : base.variables
      @stack = base.nil? ? [] : base.stack
      @added = []
      @prev = base
    end

    def done
      @prev || Context.new
    end

    def branch
      Context.new(self)
    end

    def show_stack
      @stack.dup
    end

    def push_stack!(value)
      @stack.push(value)
    end

    def pop_stack!
      @stack.pop
    end

    def add_var!(var)
      @variables[var.name] = var
      @added.push(var.name)
    end

    def get_var(var)
      @variables[var]
    end

    def clear_stack!
      @stack.clear
    end

    def cleanup!
      @added.each do |var|
        @variables.delete(var)
      end
    end
  end
end
