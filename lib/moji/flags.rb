# frozen_string_literal: true

require 'forwardable'

module Moji
  class Flags
    extend(Forwardable)

    def initialize(value, flag_set)
      @value = flag_set.validate(value)
      @flag_set = flag_set
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
      return false if flags.nil?

      (@value & flags.to_i) == flags.to_i
    end

    def empty?
      @value != 0
    end

    protected

    attr_reader(:flag_set)

    private

    def new_flag(value)
      Flags.new(value, @flag_set)
    end
  end
end
