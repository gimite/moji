require "enumerator"
require "flag_set_maker"

module Moji
  extend(FlagSetMaker)

  module Detail
    HAN_ASYMBOL_LIST= ' !"#$%&\'()*+,-./:;<=>?@[\]^_`{|}~'
    ZEN_ASYMBOL_LIST= '　！”＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿‘｛｜｝￣'
    HAN_JSYMBOL1_LIST= '｡｢｣､ｰﾞﾟ･'
    ZEN_JSYMBOL1_LIST= '。「」、ー゛゜・'
    ZEN_JSYMBOL_LIST= '、。・゛゜´｀¨ヽヾゝゞ〃仝々〆〇ー―‐＼～〜∥…‥“〔〕〈〉《》「」『』【】'+
      '±×÷≠≦≧∞∴♂♀°′″℃￠￡§☆★○●◎◇◇◆□■△▲▽▼※〒→←↑↓〓'
    HAN_KATA_LIST= 'ﾊﾋﾌﾍﾎｳｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄｱｲｴｵﾅﾆﾇﾈﾉﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｬｭｮｯ'.split(//)
    HAN_VSYMBOLS= ['', 'ﾞ', 'ﾟ']
    ZEN_KATA_LISTS= [
      'ハヒフヘホウカキクケコサシスセソタチツテトアイエオ'+
        'ナニヌネノマミムメモヤユヨラリルレロワヲンァィゥェォャュョッ',
      'バビブベボヴガギグゲゴザジズゼゾダヂヅデド',
      'パピプペポ',
    ].map(){ |s| s.split(//) }

    def self.convert_encoding(str, &block)
      orig_enc = str.encoding
      if orig_enc == Encoding::UTF_8
        # 無駄なコピーを避けるためにencodeを呼ばない。
        return yield(str)
      else
        result = yield(str.encode(Encoding::UTF_8))
        return result.is_a?(String) ? result.encode(orig_enc) : result
      end
    end
  end

  def self.uni_range(*args)
    str= args.each_slice(2).map(){ |f, e| '\u%04x-\u%04x' % [f, e] }.join("")
    return /[#{str}]/
  end

  make_flag_set([
    :HAN_CONTROL, :HAN_ASYMBOL, :HAN_JSYMBOL, :HAN_NUMBER, :HAN_UPPER, :HAN_LOWER, :HAN_KATA,
    :ZEN_ASYMBOL, :ZEN_JSYMBOL, :ZEN_NUMBER, :ZEN_UPPER, :ZEN_LOWER, :ZEN_HIRA, :ZEN_KATA,
    :ZEN_KANJI,
  ])

  HAN_SYMBOL= HAN_ASYMBOL | HAN_JSYMBOL
  HAN_ALPHA= HAN_UPPER | HAN_LOWER
  HAN_ALNUM= HAN_ALPHA | HAN_NUMBER
  HAN= HAN_CONTROL | HAN_SYMBOL | HAN_ALNUM | HAN_KATA
  ZEN_SYMBOL= ZEN_ASYMBOL | ZEN_JSYMBOL
  ZEN_ALPHA= ZEN_UPPER | ZEN_LOWER
  ZEN_ALNUM= ZEN_ALPHA | ZEN_NUMBER
  ZEN_KANA= ZEN_KATA | ZEN_HIRA
  ZEN= ZEN_SYMBOL | ZEN_ALNUM | ZEN_KANA | ZEN_KANJI
  ASYMBOL= HAN_ASYMBOL | ZEN_ASYMBOL
  JSYMBOL= HAN_JSYMBOL | ZEN_JSYMBOL
  SYMBOL= HAN_SYMBOL | ZEN_SYMBOL
  NUMBER= HAN_NUMBER | ZEN_NUMBER
  UPPER= HAN_UPPER | ZEN_UPPER
  LOWER= HAN_LOWER | ZEN_LOWER
  ALPHA= HAN_ALPHA | ZEN_ALPHA
  ALNUM= HAN_ALNUM | ZEN_ALNUM
  HIRA= ZEN_HIRA
  KATA= HAN_KATA | ZEN_KATA
  KANA= KATA | ZEN_HIRA
  KANJI= ZEN_KANJI
  ALL= HAN | ZEN

  CHAR_REGEXPS= {
    HAN_CONTROL => /[\x00-\x1f\x7f]/,
    HAN_ASYMBOL =>
      Regexp.new("["+Detail::HAN_ASYMBOL_LIST.gsub(/[\[\]\-\^\\]/){ "\\"+$& }+"]"),
    HAN_JSYMBOL => Regexp.new("["+Detail::HAN_JSYMBOL1_LIST+"]"),
    HAN_NUMBER => /[0-9]/,
    HAN_UPPER => /[A-Z]/,
    HAN_LOWER => /[a-z]/,
    HAN_KATA => /[ｦ-ｯｱ-ﾝ]/,
    ZEN_ASYMBOL => Regexp.new("["+Detail::ZEN_ASYMBOL_LIST+"]"),
    ZEN_JSYMBOL => Regexp.new("["+Detail::ZEN_JSYMBOL_LIST+"]"),
    ZEN_NUMBER => /[０-９]/,
    ZEN_UPPER => /[Ａ-Ｚ]/,
    ZEN_LOWER => /[ａ-ｚ]/,
    ZEN_HIRA => /[ぁ-ん]/,
    ZEN_KATA => /[ァ-ヶ]/,
    ZEN_KANJI => uni_range(0x3400, 0x4dbf, 0x4e00, 0x9fff, 0xf900, 0xfaff) || /[亜-瑤]/,
  }

  def type(ch)
    Detail.convert_encoding(ch) do |ch|
      ch= ch.slice(/\A./m)
      result = nil
      for tp, reg in CHAR_REGEXPS
        if ch=~reg
          result= tp
          break
        end
      end
      result
    end
  end

  def type?(ch, tp)
    Detail.convert_encoding(ch) do |ch|
      tp.include?(type(ch))
    end
  end

  def regexp(tp, encoding= nil)

    regs= []
    for tp2, reg in CHAR_REGEXPS
      regs.push(reg) if tp.include?(tp2)
    end
    reg= regs.size==1 ? regs[0] : Regexp.new(regs.join("|"))

    encoding ||= Encoding.default_internal || Encoding::UTF_8

    if encoding && encoding != Encoding::UTF_8
      return Regexp.new(reg.to_s().encode(encoding))
    else
      return reg
    end
  end

  def zen_to_han(str, tp= ALL)
    Detail.convert_encoding(str) do |str|
      if tp.include?(ZEN_KATA)
        reg= Regexp.new("[%s]" % Detail::ZEN_KATA_LISTS.flatten().join(""))
        str= str.gsub(reg) do
          for i in 0...3
            pos= Detail::ZEN_KATA_LISTS[i].index($&)
            break Detail::HAN_KATA_LIST[pos]+Detail::HAN_VSYMBOLS[i] if pos
          end
        end
      end
      str= str.tr("ａ-ｚ", "a-z") if tp.include?(ZEN_LOWER)
      str= str.tr("Ａ-Ｚ", "A-Z") if tp.include?(ZEN_UPPER)
      str= str.tr("０-９", "0-9") if tp.include?(ZEN_NUMBER)
      str= str.tr(Detail::ZEN_ASYMBOL_LIST,
        Detail::HAN_ASYMBOL_LIST.gsub(/[\-\^\\]/){ "\\"+$& }) if tp.include?(ZEN_ASYMBOL)
      str= str.tr(Detail::ZEN_JSYMBOL1_LIST,
        Detail::HAN_JSYMBOL1_LIST) if tp.include?(ZEN_JSYMBOL)
      str
    end
  end

  def han_to_zen(str, tp= ALL)
    Detail.convert_encoding(str) do |str|
      #[半]濁音記号がJSYMBOLに含まれるので、KATAの変換をJSYMBOLより前にやる必要あり。
      if tp.include?(HAN_KATA)
        str= str.gsub(/(#{han_kata})([ﾞﾟ]?)/) do
          i= {""=>0, "ﾞ"=>1, "ﾟ"=>2}[$2]
          pos= Detail::HAN_KATA_LIST.index($1)
          s= Detail::ZEN_KATA_LISTS[i][pos]
          (!s || s=="") ? Detail::ZEN_KATA_LISTS[0][pos]+$2 : s
        end
      end
      str= str.tr("a-z", "ａ-ｚ") if tp.include?(HAN_LOWER)
      str= str.tr("A-Z", "Ａ-Ｚ") if tp.include?(HAN_UPPER)
      str= str.tr("0-9", "０-９") if tp.include?(HAN_NUMBER)
      str= str.tr(Detail::HAN_ASYMBOL_LIST.gsub(/[\-\^\\]/){ "\\"+$& },
        Detail::ZEN_ASYMBOL_LIST) if tp.include?(HAN_ASYMBOL)
      str= str.tr(Detail::HAN_JSYMBOL1_LIST,
        Detail::ZEN_JSYMBOL1_LIST) if tp.include?(HAN_JSYMBOL)
      str
    end
  end

  def normalize_zen_han(str)
    Detail.convert_encoding(str) do |str|
      zen_to_han(han_to_zen(str, HAN_JSYMBOL|HAN_KATA), ZEN_ALNUM|ZEN_ASYMBOL)
    end
  end

  def upcase(str, tp= LOWER)
    Detail.convert_encoding(str) do |str|
      str= str.tr("a-z", "A-Z") if tp.include?(HAN_LOWER)
      str= str.tr("ａ-ｚ", "Ａ-Ｚ") if tp.include?(ZEN_LOWER)
      str
    end
  end

  def downcase(str, tp= UPPER)
    Detail.convert_encoding(str) do |str|
      str= str.tr("A-Z", "a-z") if tp.include?(HAN_UPPER)
      str= str.tr("Ａ-Ｚ", "ａ-ｚ") if tp.include?(ZEN_UPPER)
      str
    end
  end

  def kata_to_hira(str)
    Detail.convert_encoding(str) do |str|
      str.tr("ァ-ン", "ぁ-ん")
    end
  end

  def hira_to_kata(str)
    Detail.convert_encoding(str) do |str|
      str.tr("ぁ-ん", "ァ-ン")
    end
  end

  module_function(
    :type, :type?, :regexp, :zen_to_han, :han_to_zen, :normalize_zen_han, :upcase, :downcase,
    :kata_to_hira, :hira_to_kata
  )

  def self.define_regexp_method(name, tp)
    define_method(name) do |*args|
      regexp(tp, *args)
    end
    module_function(name)
  end

  # han_control, han_asymbol, …などのモジュール関数を定義。
  for cons in constants
    val= const_get(cons)
    define_regexp_method(cons.downcase(), val) if val.is_a?(FlagSetMaker::Flags)
  end
end
