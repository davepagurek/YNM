module YNM 
  require 'set'

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
      "#{@expressions.length} shitty instruction#{@expressions.length==0 ? "" : "s"}"
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
    DICTIONARY = Set.new(File.read('dictionary.txt').split(/\s+/))
    LETTERS = "abcdefghijklmnopqrstuvwxyz".split("")

    def to_s
      value
    end

    def value
      @expression.to_s[1..-2].scan(/(?:[a-z])+|[^a-z]+/i).map do |word|
        next word if /[^a-z]/i.match(word) || rand > 0.8
        copy_caps(mutations(word.downcase, 1).to_a.sample, word)
      end.join("")
    end

    private
    def deletes(word)
      (0..word.length-1).map{|i| word[0..i-1]+word[i+1..-1]}
    end
    def transposes(word)
      (1..word.length-1).map{|i| (word[0..i-1]+word[i+1..-1]).insert(i-1, word[i])}
    end
    def replaces(word)
      (0..word.length-1).flat_map do |i|
        LETTERS.map{|x| (word[0..i-1]+word[i+1..-1]).insert(i, x)}
      end
    end
    def inserts(word)
      (0..word.length-1).flat_map do |i|
        LETTERS.map{|x| word.dup.insert(i, x)}
      end
    end
    def mutations(word, levels, level=1)
      variations = Set.new(deletes(word) + transposes(word) + replaces(word) + inserts(word))
      if level < levels
        variations.map!{|variation| mutations(variation, levels, level+1).add(variation)}
      end
      variations.flatten.keep_if{|variation| DICTIONARY.include?(variation)}.add(word)
    end

    def copy_caps(word, source)
      if source == source.upcase
        word.upcase
      else
        word.split("").each_with_index.map do |char, i|
          if i < source.length && source[i] == source[i].upcase
            char.upcase
          else
            char.downcase
          end
        end
      end.join("")
    end
  end
end
