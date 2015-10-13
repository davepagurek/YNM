module YNM
  class Token
    def initialize(name, pattern, evaluate = nil)
      @name = name
      @pattern = /^(#{pattern})/
      @evaluate = evaluate 
    end

    def match(str)
      token = @pattern.match(str)
      token ? token[1] : nil
    end

    def name
      @name
    end

    def evaluate!(expr)
      @evaluate.call(expr) if @evaluate
    end
  end
end
