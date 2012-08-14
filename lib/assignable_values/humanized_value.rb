module AssignableValues
  class HumanizedValue

    attr_reader :value, :humanized

    def initialize(value, humanized)
      @value = value
      @humanized = humanized
    end

    def to_s
      humanized
    end

    def inspect
      "#<#{self.class.name} value: #{value.inspect}, humanized: #{humanized.inspect}>"
    end

  end
end
