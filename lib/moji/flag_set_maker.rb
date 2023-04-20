# frozen_string_literal: true

require 'forwardable'

module FlagSetMaker
  def make_flag_set(*args)
    FlagSet.new(self, *args)
  end

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

    def to_s(v)
      names = []
      @flag_names.each_with_index { |name, i| names.push(name) if v[i] == 1 }
      if names.empty?
        (@zero_name.to_s || '0')
      elsif names.size == 1
        names[0].to_s
      else
        "(#{names.join('|')})"
      end
    end

    def inspect(v = nil)
      v ? format('%p::%s', @module, to_s(v)) : super()
    end

    def validate(v)
      v & ((1 << @flag_names.size) - 1)
    end
  end

  class Flags
    extend(Forwardable)

    def initialize(v, fs)
      @value = fs.validate(v)
      @flag_set = fs
    end

    def to_i
      @value
    end

    def to_s
      @flag_set.to_s(@value)
    end

    def inspect
      @flag_set.inspect(@value)
    end

    def ==(other)
      other.is_a?(Flags) && @flag_set == other.flag_set && @value == other.to_i
    end

    alias eql? ==

    def_delegators(:to_i, :hash)

    def &(other)
      new_flag(@value & other.to_i)
    end

    def |(other)
      new_flag(@value | other.to_i)
    end

    def ~
      new_flag(~@value)
    end

    def include?(flags)
      (@value & flags.to_i) == flags.to_i
    end

    def empty?
      @value != 0
    end

    private

    attr_reader(:flag_set)

    def new_flag(v)
      Flags.new(v, @flag_set)
    end
  end
end
