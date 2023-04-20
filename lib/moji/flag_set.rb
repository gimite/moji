# frozen_string_literal: true

module Moji
  class FlagSet
    def initialize(mod, names, zero = nil)
      @module = mod
      @flag_names = names.to_a
      @zero_name = zero
      (0...@flag_names.size).each do |i|
        mod.const_set(@flag_names[i], Flags.new(1 << i, self))
      end
      mod.const_set(@zero_name, Flags.new(0, self)) if @zero_name
    end

    def to_s(value)
      names = []
      @flag_names.each_with_index { |name, i| names.push(name) if value[i] == 1 }
      if names.empty?
        (@zero_name.to_s || '0')
      elsif names.size == 1
        names[0].to_s
      else
        "(#{names.join('|')})"
      end
    end

    def inspect(value = nil)
      value ? format('%p::%s', @module, to_s(value)) : super()
    end

    def validate(value)
      value & ((1 << @flag_names.size) - 1)
    end
  end
end
