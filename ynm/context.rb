module YNM
  class Context
    attr_reader :stack, :variabled

    def initialize(base = nil)
      @variables = base ? base.variables : {}
      @stack = base ? base.stack : []
      @added = []
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
