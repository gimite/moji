# frozen_string_literal: true

require 'moji/version'
require 'moji/detail'
require 'moji/flag_set'
require 'moji/flags'

module Moji
  def self.uni_range(*args)
    str = args.each_slice(2).map { |f, e| format('\u%04x-\u%04x', f, e) }.join
    /[#{str}]/
  end

  def self.make_flag_set(*args)
    FlagSet.new(self, *args)
  end

  make_flag_set(%i[
                  HAN_CONTROL HAN_ASYMBOL HAN_JSYMBOL HAN_NUMBER HAN_UPPER HAN_LOWER HAN_KATA
                  ZEN_ASYMBOL ZEN_JSYMBOL ZEN_NUMBER ZEN_UPPER ZEN_LOWER ZEN_HIRA ZEN_KATA
                  ZEN_KANJI
                ])

  HAN_SYMBOL = HAN_ASYMBOL | HAN_JSYMBOL
  HAN_ALPHA = HAN_UPPER | HAN_LOWER
  HAN_ALNUM = HAN_ALPHA | HAN_NUMBER
  HAN = HAN_CONTROL | HAN_SYMBOL | HAN_ALNUM | HAN_KATA
  ZEN_SYMBOL = ZEN_ASYMBOL | ZEN_JSYMBOL
  ZEN_ALPHA = ZEN_UPPER | ZEN_LOWER
  ZEN_ALNUM = ZEN_ALPHA | ZEN_NUMBER
  ZEN_KANA = ZEN_KATA | ZEN_HIRA
  ZEN = ZEN_SYMBOL | ZEN_ALNUM | ZEN_KANA | ZEN_KANJI
  ASYMBOL = HAN_ASYMBOL | ZEN_ASYMBOL
  JSYMBOL = HAN_JSYMBOL | ZEN_JSYMBOL
  SYMBOL = HAN_SYMBOL | ZEN_SYMBOL
  NUMBER = HAN_NUMBER | ZEN_NUMBER
  UPPER = HAN_UPPER | ZEN_UPPER
  LOWER = HAN_LOWER | ZEN_LOWER
  ALPHA = HAN_ALPHA | ZEN_ALPHA
  ALNUM = HAN_ALNUM | ZEN_ALNUM
  HIRA = ZEN_HIRA
  KATA = HAN_KATA | ZEN_KATA
  KANA = KATA | ZEN_HIRA
  KANJI = ZEN_KANJI
  ALL = HAN | ZEN

  CHAR_REGEXPS = {
    HAN_CONTROL => /[\x00-\x1f\x7f]/,
    HAN_ASYMBOL =>
      Regexp.new("[#{Detail::HAN_ASYMBOL_LIST.gsub(/[\[\]\-\^\\]/) { "\\#{::Regexp.last_match(0)}" }}]"),
    HAN_JSYMBOL => Regexp.new("[#{Detail::HAN_JSYMBOL1_LIST}]"),
    HAN_NUMBER => /[0-9]/,
    HAN_UPPER => /[A-Z]/,
    HAN_LOWER => /[a-z]/,
    HAN_KATA => /[ｦ-ｯｱ-ﾝ]/,
    ZEN_ASYMBOL => Regexp.new("[#{Detail::ZEN_ASYMBOL_LIST}]"),
    ZEN_JSYMBOL => Regexp.new("[#{Detail::ZEN_JSYMBOL_LIST}]"),
    ZEN_NUMBER => /[０-９]/,
    ZEN_UPPER => /[Ａ-Ｚ]/,
    ZEN_LOWER => /[ａ-ｚ]/,
    ZEN_HIRA => /[ぁ-ん]/,
    ZEN_KATA => /[ァ-ヶ]/,
    ZEN_KANJI => uni_range(0x3400, 0x4dbf, 0x4e00, 0x9fff, 0xf900, 0xfaff) || /[亜-瑤]/
  }.freeze

  def type(char)
    Detail.convert_encoding(char) do |ch|
      ch = ch.slice(/\A./m)
      result = nil
      CHAR_REGEXPS.each do |tp, reg|
        if ch&.match?(reg)
          result = tp
          break
        end
      end
      result
    end
  end

  def type?(char, types)
    Detail.convert_encoding(char) do |ch|
      types.include?(type(ch))
    end
  end

  def regexp(types, encoding = nil)
    regs = []
    CHAR_REGEXPS.each do |tp2, reg|
      regs.push(reg) if types.include?(tp2)
    end
    reg = regs.size == 1 ? regs[0] : Regexp.new(regs.join('|'))

    encoding ||= Encoding.default_internal || Encoding::UTF_8

    return Regexp.new(reg.to_s.encode(encoding)) if encoding && encoding != Encoding::UTF_8

    reg
  end

  def zen_to_han(string, types = ALL)
    Detail.convert_encoding(string) do |str|
      if types.include?(ZEN_KATA)
        reg = Regexp.new(format('[%s]', Detail::ZEN_KATA_LISTS.flatten.join))
        str = str.gsub(reg) do
          3.times do |i|
            pos = Detail::ZEN_KATA_LISTS[i].index(::Regexp.last_match(0))
            break Detail::HAN_KATA_LIST[pos] + Detail::HAN_VSYMBOLS[i] if pos
          end
        end
      end
      str = str.tr('ａ-ｚ', 'a-z') if types.include?(ZEN_LOWER)
      str = str.tr('Ａ-Ｚ', 'A-Z') if types.include?(ZEN_UPPER)
      str = str.tr('０-９', '0-9') if types.include?(ZEN_NUMBER)
      if types.include?(ZEN_ASYMBOL)
        str = str.tr(Detail::ZEN_ASYMBOL_LIST,
                     Detail::HAN_ASYMBOL_LIST.gsub(/[-\^\\]/) do
                       "\\#{::Regexp.last_match(0)}"
                     end)
      end
      if types.include?(ZEN_JSYMBOL)
        str = str.tr(Detail::ZEN_JSYMBOL1_LIST,
                     Detail::HAN_JSYMBOL1_LIST)
      end
      str
    end
  end

  def han_to_zen(string, types = ALL)
    Detail.convert_encoding(string) do |str|
      # [半]濁音記号がJSYMBOLに含まれるので、KATAの変換をJSYMBOLより前にやる必要あり。
      if types.include?(HAN_KATA)
        str = str.gsub(/(#{han_kata})([ﾞﾟ]?)/) do
          i = { '' => 0, 'ﾞ' => 1, 'ﾟ' => 2 }[::Regexp.last_match(2)]
          pos = Detail::HAN_KATA_LIST.index(::Regexp.last_match(1))
          s = Detail::ZEN_KATA_LISTS[i][pos]
          !s || s == '' ? Detail::ZEN_KATA_LISTS[0][pos] + ::Regexp.last_match(2) : s
        end
      end
      str = str.tr('a-z', 'ａ-ｚ') if types.include?(HAN_LOWER)
      str = str.tr('A-Z', 'Ａ-Ｚ') if types.include?(HAN_UPPER)
      str = str.tr('0-9', '０-９') if types.include?(HAN_NUMBER)
      if types.include?(HAN_ASYMBOL)
        str = str.tr(Detail::HAN_ASYMBOL_LIST.gsub(/[-\^\\]/) { "\\#{::Regexp.last_match(0)}" },
                     Detail::ZEN_ASYMBOL_LIST)
      end
      if types.include?(HAN_JSYMBOL)
        str = str.tr(Detail::HAN_JSYMBOL1_LIST,
                     Detail::ZEN_JSYMBOL1_LIST)
      end
      str
    end
  end

  def normalize_zen_han(string)
    Detail.convert_encoding(string) do |str|
      zen_to_han(han_to_zen(str, HAN_JSYMBOL | HAN_KATA), ZEN_ALNUM | ZEN_ASYMBOL)
    end
  end

  def upcase(string, types = LOWER)
    Detail.convert_encoding(string) do |str|
      str = str.tr('a-z', 'A-Z') if types.include?(HAN_LOWER)
      str = str.tr('ａ-ｚ', 'Ａ-Ｚ') if types.include?(ZEN_LOWER)
      str
    end
  end

  def downcase(string, types = UPPER)
    Detail.convert_encoding(string) do |str|
      str = str.tr('A-Z', 'a-z') if types.include?(HAN_UPPER)
      str = str.tr('Ａ-Ｚ', 'ａ-ｚ') if types.include?(ZEN_UPPER)
      str
    end
  end

  def kata_to_hira(string)
    Detail.convert_encoding(string) do |str|
      str.tr('ァ-ン', 'ぁ-ん')
    end
  end

  def hira_to_kata(string)
    Detail.convert_encoding(string) do |str|
      str.tr('ぁ-ん', 'ァ-ン')
    end
  end

  module_function(
    :type, :type?, :regexp, :zen_to_han, :han_to_zen, :normalize_zen_han, :upcase, :downcase,
    :kata_to_hira, :hira_to_kata
  )

  def self.define_regexp_method(name, types)
    define_method(name) do |*args|
      regexp(types, *args)
    end
    module_function(name)
  end

  # han_control, han_asymbol, …などのモジュール関数を定義。
  constants.each do |cons|
    val = const_get(cons)
    define_regexp_method(cons.downcase, val) if val.is_a?(::Moji::Flags)
  end
end
