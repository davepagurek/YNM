class YNM
  RUN = "do"
  BLOCK_START = "work"
  BLOCK_RESCUE = "oops"
  BLOCK_END = "please"
  STATEMENT_END = "\n"
  GROUP_START = "("
  GROUP_END = ")"
  CONDITIONAL_START = "assuming"
  CONDITIONAL_ELSE = "backup"
  FUNCTION_START = "chore"
  PRINT = "say"

  class Context
    def initialize
    end
  end

  class Interpreter
    def initialize(input = [], context = Context.new, &return_to)
      @tokens = input
      @context = context
    end

    def get_token!
      @tokens.shift
    end

    def run!(block = false)
      while token = get_token!
        puts token
        case token
        when RUN
        when BLOCK_START

        end
      end
    end
  end

  def self.interpret(input = "")
    # Split strings by whitespace (keeping newlines) and word breaks
    start = Time.now
    Interpreter.new(input.split(/[^\S\n]+|\b/)).run! do |_, error|
      if error puts "Unhandled tantrum: #{error}"
      else puts "Program finished successfully in #{Time.now-start}s."
      end
    end
  end
end

YNM.interpret('say("hi")')
