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
        Token.new(:run, "do", Proc.new do |_, context|
          run_count!(1)
          func = context.pop_stack!
          #innerCtx = Context.new(@context)
          func.expressions.reverse_each do |e|
            #e.evaluate!(innerCtx)
            @instructions.push(e)
          end
          @instructions.push(Expression.new("please", @tokens[2]))
          run_to!(:block_end)
          #innerCtx.cleanup!
        end),
        Token.new(:block_start, "work", Proc.new do |_, context|
          func = YNMFunction.new(get_expressions!(:block_end))
          context.push_stack!(func)
        end),
        Token.new(:block_end, "please"),
        Token.new(:block_rescue, "oops"),
        Token.new(:statement_end, '\n', Proc.new do |_, context|
          @after_each.call(context.pop_stack!) if @after_each
          #context.clear_stack!
        end),
        Token.new(:group_start, '\(', Proc.new do |_, context|
          run_to!(:group_end)
        end),
        Token.new(:group_end, '\)'),
        Token.new(:conditional_start, 'assuming'),
        Token.new(:conditional_else, 'backup'),
        Token.new(:print, 'say', Proc.new do |_, context|
          run_count!(1)
          if e = context.pop_stack!
            puts e.to_s
          else
            puts "didn't do shit"
          end
        end),
        Token.new(:bool, '(?:yes|no|maybe)', Proc.new do |expr, context|
          context.push_stack!(YNMBoolean.new(expr))
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
          @input = @input[t.length..@input.length]
          return Expression.new(t, token) 
        end
      end
      nil
    end

    def run_count!(count)
      iterations = 0
      until iterations == count
        if (e = @instructions.pop)
          e.evaluate!(@context)
          iterations += 1 unless e.is_token?(:whitespace, :comment)
        else
          break
        end
      end
    end

    def run!(*to)
      while expr = @instructions.pop
        expr.evaluate!(@context)
        break if expr.is_token?(*to)
      end
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
