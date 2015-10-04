module YNM
  require_relative('./ynm/token.rb')
  require_relative('./ynm/expression.rb')
  require_relative('./ynm/context.rb')
  require_relative('./ynm/variables.rb')

  class Interpreter
    def initialize(input = [], ctx = Context.new, return_to = nil)
      @input = input
      @context = ctx
      @tokens = [
        Token.new(:run, "do"),
        Token.new(:block_start, "work"),
        Token.new(:block_end, "please"),
        Token.new(:block_rescue, "oops"),
        Token.new(:statement_end, '\n', Proc.new do |_, context|
          context.clear_stack!
        end),
        Token.new(:group_start, '\(', Proc.new do  |_, context|
          run_to!(:group_end)
        end),
        Token.new(:group_end, '\)'),
        Token.new(:conditional_start, 'assuming'),
        Token.new(:conditional_else, 'backup'),
        Token.new(:print, 'say', Proc.new do |_, context|
          run_count!(1)
          puts context.pop_stack!.value
        end),
        Token.new(:true, 'probably', Proc.new do |_, context|
          context.push_stack!(YNMBoolean.new(true))
        end),
        Token.new(:false, 'unlikely', Proc.new do |_, context|
          context.push_stack!(YNMBoolean.new(false))
        end),
        Token.new(:string, '"(?:[^"\\\\]|\\\\.)*"', Proc.new do |expr, context|
          context.push_stack!(YNMString.new(expr))
        end),
        Token.new(:variable, '\w+'),
        Token.new(:whitespace, '\s+')
      ]
    end 

    def get_expression!
      @tokens.each do |token|
        if t = token.match(@input)
          @input = @input[t.length, @input.length]
          return Expression.new(t, token) 
        end
      end
      nil
    end

    def run_count!(count)
      iterations = 0
      until iterations == count
        if (e = get_expression!)
          e.evaluate!(@context)
          iterations += 1 unless e.is_token?(:whitespace, :comment)
        else
          break
        end
      end
    end

    def run!(*to)
      while expr = get_expression!
        expr.evaluate!(@context)
        break if expr.is_token?(*to)
      end
    end

    def run_to!(*to)
      run!(*to)
    end

    def get_expressions!(*to)
      expressions = []
      while expr = get_expression!
        expressions << expr
        return expressions if expr.is_token?(to)
      end
      expressions
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

YNM.interpret(%q{
  say("Hello, world!")
  say("hi there")
})
