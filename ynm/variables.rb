module YNM
  class Value
    def initialize(expression)
      @expression = expression
    end

    def value
    end
  end

  class YNMString < Value
    def value
      @expression.to_s[1..-2]
    end
  end
end
