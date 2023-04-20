# frozen_string_literal: true

module Moji
  module Detail
    HAN_ASYMBOL_LIST = ' !"#$%&\'()*+,-./:;<=>?@[\]^_`{|}~'
    ZEN_ASYMBOL_LIST = '　！”＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿‘｛｜｝￣'
    HAN_JSYMBOL1_LIST = '｡｢｣､ｰﾞﾟ･'
    ZEN_JSYMBOL1_LIST = '。「」、ー゛゜・'
    ZEN_JSYMBOL_LIST = '、。・゛゜´｀¨ヽヾゝゞ〃仝々〆〇ー―‐＼～〜∥…‥“〔〕〈〉《》「」『』【】' \
                       '±×÷≠≦≧∞∴♂♀°′″℃￠￡§☆★○●◎◇◇◆□■△▲▽▼※〒→←↑↓〓'
    HAN_KATA_LIST = 'ﾊﾋﾌﾍﾎｳｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄｱｲｴｵﾅﾆﾇﾈﾉﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｬｭｮｯ'.chars
    HAN_VSYMBOLS = ['', 'ﾞ', 'ﾟ'].freeze
    ZEN_KATA_LISTS = [
      'ハヒフヘホウカキクケコサシスセソタチツテトアイエオ' \
      'ナニヌネノマミムメモヤユヨラリルレロワヲンァィゥェォャュョッ',
      'バビブベボヴガギグゲゴザジズゼゾダヂヅデド',
      'パピプペポ'
    ].map(&:chars)

    def self.convert_encoding(string)
      orig_encoding = string.encoding
      return yield(string) if orig_encoding == Encoding::UTF_8

      # 無駄なコピーを避けるためにencodeを呼ばない。
      result = yield(string.encode(Encoding::UTF_8))
      result.is_a?(String) ? result.encode(orig_encoding) : result
    end
  end
end
