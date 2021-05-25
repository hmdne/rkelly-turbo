module RKelly
  class Token
    attr_accessor :name, :value, :transformer, :range
    def initialize(name, value, &transformer)
      @name         = name
      @value        = value
      @transformer  = transformer if transformer
    end

    # For backwards compatibility
    def line
      @range.from.line
    end

    def to_racc_token
      if @transformer
        @name, @value = @transformer.call(@name, @value)
        @transformer = nil
      end
      [@name, @value]
    end

    def to_s
      return "#{self.name}: #{self.value}"
    end
  end
end
