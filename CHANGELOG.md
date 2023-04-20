# Changelog

### 2023/04/21 - v2.0.0

- Remove GREEK, CYRILLIC, and LINE constants.
- Drop support for Ruby 2.5 and earlier.
- Add Rubocop.
- Add Github Actions.
- Add RSpec tests.
- Code cleanup.

### 2010/9/19 - v1.5.0

- Ruby 1.9に対応。

### 2008/8/30 - v1.4.0

- Moji.type("\n")がnilを返すバグを修正。(thanks to 橋爪さん)

### 2006/7/23 - v1.3.0

- 半角中黒(･)の字種判別、全角中黒との相互変換ができていなかったのを修正。(thanks to xyzzyさん)

### 2006/10/5 - v1.2.0

- *EUC 以外の文字コードにも対応し、ライブラリ名を Moji に変更。
- han_to_zen, zen_to_han の対象文字種のデフォルトを全て( (({ALL})) )に。
- normalize_zen_han 追加。

### 2005/1/3 - v1.1.0

- (({$KCODE})) が指定されていないとEUCUtil.typeが正常動作しない問題を修正。
- 定数に (({ASYMBOL})) と (({JSYMBOL})) を追加。

### 2004/11/16 - v1.0.0

- EUCUtil 公開。
