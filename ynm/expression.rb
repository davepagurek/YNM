module YNM
  class Expression
    attr_reader :literal 

    def initialize(literal, token)
      @literal = literal
      @token = token
    end

    def to_s 
      @literal
    end

    def inspect
      "#{@token.name}(#{@literal.gsub(/\s+/, " ")})"
    end

    def is_token?(*types)
      types.include?(@token.name)
    end

    def evaluate!
      @token.evaluate!(self)
    end
  end
end

