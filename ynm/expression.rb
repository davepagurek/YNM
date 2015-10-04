module YNM
  class Expression
    def initialize(literal, token)
      @literal = literal
      @token = token
    end

    def to_s 
      @literal
    end

    def is_token?(types = [])
      types.nil? ? false : types.include?(@token.name)
    end

    def evaluate!(context)
      @token.evaluate!(self, context)
    end
  end
end

