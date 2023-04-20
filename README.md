# Moji モジュール

日本語の文字種判定、文字種変換(半角→全角、ひらがな→カタカナなど)を行います。

## インストール:

以下のコマンドを実行してください。

  $ sudo gem install moji

## 使い方:

どの文字コードの文字列を渡しても大丈夫ですが、 String#encoding が正しく設定されている
必要があります。正規表現を返す関数( Moji.kata など)は Encoding.default_internal
(設定されてない場合はUTF-8)用の正規表現を返します。その他のエンコーディング用の正規表現は
Moji.kata(Encoding::SJIS) などで取得できます。

```ruby
require "moji"

#文字種判定。
p Moji.type("漢")                                    # => Moji::ZEN_KANJI
p Moji.type?("Ａ", Moji::ZEN)                        # => true

#文字種変換。
p Moji.zen_to_han("Ｒｕｂｙ")                        # => "Ruby"
p Moji.upcase("Ｒｕｂｙ")                            # => "ＲＵＢＹ"
p Moji.kata_to_hira("ルビー")                        # => "るびー"

#文字種による正規表現。
p /#{Moji.kata}+#{Moji.hira}+/ =~ "ぼくドラえもん"   # => 6
p Regexp.last_match.to_s                             # => "ドラえもん"
```

## 定数

以下の定数は、文字種の一番細かい分類です。
(({Moji.type})) が返すのは、以下の定数のうちの1つです。

--- HAN_CONTROL
    制御文字。
--- HAN_ASYMBOL
    ASCIIに含まれる半角記号。
--- HAN_JSYMBOL
    JISに含まれるがASCIIには含まれない半角記号。
--- HAN_NUMBER
    半角数字。
--- HAN_UPPER
    半角アルファベット大文字。
--- HAN_LOWER
    半角アルファベット小文字。
--- HAN_KATA
    半角カタカナ。
--- ZEN_ASYMBOL
    JISの全角記号のうち、ASCIIに対応する半角記号があるもの。
--- ZEN_JSYMBOL
    JISの全角記号のうち、ASCIIに対応する半角記号がないもの。
--- ZEN_NUMBER
    全角数字。
--- ZEN_UPPER
    全角アルファベット大文字。
--- ZEN_LOWER
    全角アルファベット小文字。
--- ZEN_HIRA
    ひらがな。
--- ZEN_KATA
    全角カタカナ。
--- ZEN_KANJI
    漢字。

以下の定数は、上の文字種の組み合わせと別名です。

--- HAN_SYMBOL
    JISに含まれる半角記号。(({HAN_ASYMBOL | HAN_JSYMBOL}))
--- HAN_ALPHA
    半角アルファベット。(({HAN_UPPER | HAN_LOWER}))
--- HAN_ALNUM
    半角英数字。(({HAN_ALPHA | HAN_NUMBER}))
--- HAN
    全ての半角文字。(({HAN_CONTROL | HAN_SYMBOL | HAN_ALNUM | HAN_KATA}))
--- ZEN_SYMBOL
    JISに含まれる全角記号。(({ZEN_ASYMBOL | ZEN_JSYMBOL}))
--- ZEN_ALPHA
    全角アルファベット。(({ZEN_UPPER | ZEN_LOWER}))
--- ZEN_ALNUM
    全角英数字。(({ZEN_ALPHA | ZEN_NUMBER}))
--- ZEN_KANA
    全角かな/カナ。(({ZEN_KATA | ZEN_HIRA}))
--- ZEN
    JISに含まれる全ての全角文字。(({ZEN_SYMBOL | ZEN_ALNUM | ZEN_KANA | ZEN_KANJI}))
--- ASYMBOL
    ASCIIに含まれる半角記号とその全角版。(({HAN_ASYMBOL | ZEN_ASYMBOL}))
--- JSYMBOL
    JISに含まれるが (({ASYMBOL})) には含まれない全角/半角記号。(({HAN_JSYMBOL | ZEN_JSYMBOL}))
--- SYMBOL 
    JISに含まれる全ての全角/半角記号。(({HAN_SYMBOL | ZEN_SYMBOL}))
--- NUMBER
    全角/半角数字。(({HAN_NUMBER | ZEN_NUMBER}))
--- UPPER
    全角/半角アルファベット大文字。(({HAN_UPPER | ZEN_UPPER}))
--- LOWER
    全角/半角アルファベット小文字。(({HAN_LOWER | ZEN_LOWER}))
--- ALPHA
    全角/半角アルファベット。(({HAN_ALPHA | ZEN_ALPHA}))
--- ALNUM
    全角/半角英数字。(({HAN_ALNUM | ZEN_ALNUM}))
--- HIRA
    (({ZEN_HIRA})) の別名。
--- KATA
    全角/半角カタカナ。(({HAN_KATA | ZEN_KATA}))
--- KANA
    全角/半角 かな/カナ。(({KATA | ZEN_HIRA}))
--- KANJI
    (({ZEN_KANJI})) の別名。
--- ALL
    上記全ての文字。

## モジュール関数

--- Moji.type(ch)

    文字 ((|ch|)) の文字種を返します。

    「一番細かい分類」の((<定数|定数:>))のうち1つを返します。

    上の分類に当てはまらない文字(Unicodeのハングルなど)に対しては (({nil})) を返します。
    また、UnicodeのB面以降の文字に対しても (({nil})) を返します。

    文字が割り当てられていない文字コードに対する結果は不定です( (({nil})) を返す事もあります)。

      p Moji.type("漢")   # => Moji::ZEN_KANJI

--- Moji.type?(ch, type)

    文字 ((|ch|)) が文字種 ((|type|)) に含まれれば、 (({true})) を返します。

    ((|type|)) には全ての((<定数|定数:>))と、それらを (({|}))
    で結んだものを使えます。

      p Moji.type?("Ａ", Moji::ZEN)   # => true

--- Moji.regexp(type[, encoding])

    文字種 ((|type|)) の1文字を表す正規表現を返します。

    ((|type|)) には全ての((<定数|定数:>))と、それらを (({|}))
    で結んだものを使えます。

    Ruby 1.9では ((|encoding|)) に Encoding オブジェクトを渡すと、指定のエンコーディング用の
    正規表現を返します。
    省略すると Encoding.default_internal (指定されてない場合は Encoding::UTF_8 )とみなします。

      p Moji.regexp(Moji::HIRA)   # => /[ぁ-ん]/

--- Moji.zen_to_han(str[, type])

    文字列 ((|str|)) の全角を半角に変換して返します。

    ((|type|)) には、変換対象とする文字種を((<定数|定数:>))で指定します。
    デフォルトは (({ALL})) (全て)です。

      p Moji.zen_to_han("Ｒｕｂｙ！？")                # => "Ruby!?"
      p Moji.zen_to_han("Ｒｕｂｙ！？", Moji::ALPHA)   # => "Ruby！？"

--- Moji.han_to_zen(str[, type])

    文字列 ((|str|)) の半角を全角に変換して返します。

    ((|type|)) には、変換対象とする文字種を((<定数|定数:>))で指定します。
    デフォルトは (({ALL})) (全て)です。

      p Moji.han_to_zen("Ruby!?")                 # => "Ｒｕｂｙ！？"
      p Moji.han_to_zen("Ruby!?", Moji::SYMBOL)   # => "Ruby！？"

--- Moji.normalize_zen_han(str)

    文字列 ((|str|)) の大文字、小文字を一般的なものに統一します。

    具体的には、ASCIIに含まれる記号と英数字( (({ALNUM|ASYMBOL}))
    )を半角に、それ以外の記号とカタカナ( (({JSYMBOL|HAN_KATA})) )を全角に変換します。

--- Moji.upcase(str[, type])

    文字列 ((|str|)) の小文字を大文字に変換して返します。

    ((|type|)) には、変換対象とする文字種を((<定数|定数:>))で指定します。
    デフォルトは (({LOWER})) (全角/半角のアルファベット)です。
    ギリシャ文字、キリル文字には対応していません。

      p Moji.upcase("Ｒｕｂｙ")   # => "ＲＵＢＹ"

--- Moji.downcase(str[, type])

    文字列 ((|str|)) の小文字を大文字に変換して返します。

    ((|type|)) には、変換対象とする文字種を((<定数|定数:>))で指定します。
    デフォルトは (({UPPER})) (全角/半角のアルファベット)です。
    ギリシャ文字、キリル文字には対応していません。

      p Moji.downcase("Ｒｕｂｙ")   # => "ｒｕｂｙ"

--- Moji.kata_to_hira(str)

    文字列 ((|str|)) の全角カタカナをひらがなに変換して返します。

    半角カタカナは直接変換できません。 (({han_to_zen})) で全角にしてから変換してください。

      p Moji.kata_to_hira("ルビー")   # => "るびー"

--- Moji.hira_to_kata(str)

    文字列 ((|str|)) のひらがなを全角カタカナに変換して返します。

      p Moji.hira_to_kata("るびー")   # => "ルビー"

--- Moji.han_control([encoding])
--- Moji.han_asymbol([encoding])
--- ...
--- Moji.kana([encoding])
--- ...

    ((<定数|定数:>))それぞれに対応するメソッドが有り、
    それぞれの文字種の1文字を表す正規表現を返します。

    例えば、 (({Moji.kana})) は (({Moji.regexp(Moji::KANA)})) と同じです。

    Ruby 1.9では ((|encoding|)) に Encoding オブジェクトを渡すと、指定のエンコーディング用の
    正規表現を返します。
    省略すると Encoding.default_internal (指定されてない場合は Encoding::UTF_8 )とみなします。

    以下の例のように、文字クラスっぽく使えます。
      p /#{Moji.kata}+#{Moji.hira}+/ =~ "ぼくドラえもん"   # => 6
      p Regexp.last_match.to_s                             # => "ドラえもん"

## 動作環境

Ruby 1.9.2にて動作確認しました。

## 作者

Gimite 市川

## ライセンス

Public Domainです。煮るなり焼くなりご自由に。

## Github

((<URL:https://github.com/gimite/moji>))
