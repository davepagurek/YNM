module YNM
  class Value
    def initialize(expression)
      @expression = expression
    end

    def value
      self
    end

    def to_s
      self.inspect
    end
  end

  class YNMFunction < Value
    def initialize(expressions)
      @expressions = expressions
    end

    def expressions
      @expressions
    end

    def to_s
      "some shit that can be done maybe"
    end
  end

  class YNMBoolean < Value
    TRUTHS = ["yes", "yeah", "yep", "true", "correct"]
    FALSEHOODS = ["no", "nope", "nahh", "no way", "false"]

    def value
      if @expression.literal == "yes"
        rand > 0.3
      elsif @expression.literal == "no"
        rand > 0.7
      else
        rand > 0.5
      end
    end

    def to_s
      value ? TRUTHS.sample : FALSEHOODS.sample
    end
  end

  class YNMString < Value
    require 'levenshtein'
    DICTIONARY = File.read('dictionary.txt').split(/\s+/).group_by{|w| w[0]}
    LETTERS = "abcdefghijklmnopqrstuvwxyz".split("")

    def to_s
      value
    end

    def value
      @expression.to_s[1..-2].split("").map do |char|
        if /[a-z]/i.match(char) && rand > 0.8 
          letter = LETTERS.sample 
          char == char.upcase ? letter.upcase : letter
        else
          char
        end
      end.join("").split(/\s+/).map do |word|
        if /^[a-z]/i.match(word)
          DICTIONARY[word[0].downcase].map do |entry|
           [entry, Levenshtein.distance(entry, word)]
          end.sort do |a, b|
            a[1] <=> b[1]
          end.first[0]
        else
          word
        end
      end.join(" ")
    end
  end
end
