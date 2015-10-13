module YNM
  require_relative('./ynm/token.rb')
  require_relative('./ynm/expression.rb')
  require_relative('./ynm/context.rb')
  require_relative('./ynm/variables.rb')

  class Interpreter
    def initialize(input = "", after_each = nil)
      @input = input
      @instructions = []
      @context = Context.new
      @after_each = after_each
      @tokens = [
        Token.new(:run, "do", Proc.new do
          run_count!(1)
          func = @context.pop_stack!
          branch_context!
          @instructions.push(Expression.new("please", get_token(:block_end)))
          func.expressions.reverse_each do |e|
            @instructions.push(e)
          end
          run_to!(:block_end)
          last = @context.pop_stack!
          pop_context!
          @context.push_stack!(last)
        end),
        Token.new(:block_start, "work", Proc.new do
          func = YNMFunction.new(get_expressions!(:block_end))
          @context.push_stack!(func)
        end),
        Token.new(:block_end, "please"),
        Token.new(:block_rescue, "oops"),
        Token.new(:statement_end, '\n', Proc.new do 
        end),
        Token.new(:group_start, '\(', Proc.new do
          run_to!(:group_end)
        end),
        Token.new(:group_end, '\)'),
        Token.new(:conditional_start, 'assuming'),
        Token.new(:conditional_else, 'backup'),
        Token.new(:print, 'say', Proc.new do
          run_count!(1)
          if e = @context.pop_stack!
            puts e.to_s
          else
            puts "didn't do shit"
          end
          @context.push_stack!(nil)
          #TODO: provide a return value (null?)
        end),
        Token.new(:bool, '(?:yes|no|maybe)', Proc.new do |expr|
          @context.push_stack!(YNMBoolean.new(expr))
        end),
        Token.new(:string, '"(?:[^"\\\\]|\\\\.)*"', Proc.new do |expr|
          @context.push_stack!(YNMString.new(expr))
        end),
        Token.new(:variable, '\w+'),
        Token.new(:whitespace, '\s+')
      ]
    end 

    def branch_context!
      @context = @context.branch
    end

    def pop_context!
      @context.cleanup!
      @context = @context.done
    end

    def get_token(type)
      @tokens.find{|token| token.name == type}
    end

    def get_expression!
      @tokens.each do |token|
        if t = token.match(@input)
          @input = @input[t.length..@input.length]
          return Expression.new(t, token) 
        end
      end
      nil
    end

    def run_count!(count)
      iterations = 0
      until iterations == count
        e = @instructions.pop
        break if e.nil?
        e.evaluate!
        iterations += 1 unless e.is_token?(:whitespace, :comment)
      end
    end

    def run!(*to)
      while expr = @instructions.pop
        expr.evaluate!
        break if expr.is_token?(*to)
      end
      @after_each.call(@context.pop_stack!) if @after_each && to.empty?
    end

    def run_to!(*to)
      run!(*to)
    end

    def get_expressions!(*to)
      expressions = []
      while expr = @instructions.pop
        return expressions if expr.is_token?(*to)
        expressions << expr
      end
      expressions
    end

    def add_input!(str)
      @input = "#{@input} #{str}"
      while expr = get_expression!
        @instructions.unshift(expr)
      end
    end
  end

  def self.interpret(input = "")
    # Split strings by whitespace (keeping newlines) and word breaks
    start = Time.now
    Interpreter.new(input).run! do |_, error|
      if error puts "Unhandled tantrum: #{error}"
      else puts "Program finished successfully in #{Time.now-start}s."
      end
    end
  end
end
