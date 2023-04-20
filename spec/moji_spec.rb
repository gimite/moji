# frozen_string_literal: true

require_relative 'spec_helper'

describe Moji do
  let(:str) { 'ドﾗえもん(DorＡｅmon)は、日本で1番有名な漫画だ。' }

  describe '::zen_to_han' do
    let(:conv) { described_class.zen_to_han(str) }
    let(:exp) { 'ﾄﾞﾗえもん(DorAemon)は､日本で1番有名な漫画だ｡' }

    it { expect(conv).to eq(exp) }
  end

  describe '::han_to_zen' do
    let(:conv) { described_class.han_to_zen(str) }
    let(:exp)  { 'ドラえもん（ＤｏｒＡｅｍｏｎ）は、日本で１番有名な漫画だ。' }

    it { expect(conv).to eq(exp) }
  end

  describe '::normalize_zen_han' do
    let(:conv) { described_class.normalize_zen_han(str) }
    let(:exp) { 'ドラえもん(DorAemon)は、日本で1番有名な漫画だ。' }

    it { expect(conv).to eq(exp) }

    context 'when Shift-JIS string' do
      let(:conv) { described_class.normalize_zen_han(str.encode(Encoding::SJIS)).encode(Encoding::UTF_8) }

      it { expect(conv).to eq(exp) }
    end
  end

  describe '::kata_to_hira' do
    let(:conv) { described_class.kata_to_hira(str) }
    let(:exp) { 'どﾗえもん(DorＡｅmon)は、日本で1番有名な漫画だ。' }

    it { expect(conv).to eq(exp) }
  end

  describe '::hira_to_kata' do
    let(:conv) { described_class.hira_to_kata(str) }
    let(:exp) { 'ドﾗエモン(DorＡｅmon)ハ、日本デ1番有名ナ漫画ダ。' }

    it { expect(conv).to eq(exp) }
  end

  describe '::upcase' do
    let(:conv) { described_class.upcase(str) }
    let(:exp) { 'ドﾗえもん(DORＡＥMON)は、日本で1番有名な漫画だ。' }

    it { expect(conv).to eq(exp) }
  end

  describe '::downcase' do
    let(:conv) { described_class.downcase(str) }
    let(:exp) { 'ドﾗえもん(dorａｅmon)は、日本で1番有名な漫画だ。' }

    it { expect(conv).to eq(exp) }
  end

  describe '::type' do
    let(:exp) do
      [Moji::ZEN_KATA,
       Moji::HAN_KATA,
       Moji::ZEN_HIRA,
       Moji::ZEN_HIRA,
       Moji::ZEN_HIRA,
       Moji::HAN_ASYMBOL,
       Moji::HAN_UPPER,
       Moji::HAN_LOWER,
       Moji::HAN_LOWER,
       Moji::ZEN_UPPER,
       Moji::ZEN_LOWER,
       Moji::HAN_LOWER,
       Moji::HAN_LOWER,
       Moji::HAN_LOWER,
       Moji::HAN_ASYMBOL,
       Moji::ZEN_HIRA,
       Moji::ZEN_JSYMBOL,
       Moji::ZEN_KANJI,
       Moji::ZEN_KANJI,
       Moji::ZEN_HIRA,
       Moji::HAN_NUMBER,
       Moji::ZEN_KANJI,
       Moji::ZEN_KANJI,
       Moji::ZEN_KANJI,
       Moji::ZEN_HIRA,
       Moji::ZEN_KANJI,
       Moji::ZEN_KANJI,
       Moji::ZEN_HIRA,
       Moji::ZEN_JSYMBOL]
    end

    it 'maps the types' do
      expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
    end

    context 'when hankaku katakana' do
      let(:str) { 'ﾗ' }
      let(:exp) { [Moji::HAN_KATA] }

      it 'maps the types' do
        expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
      end

      it 'considers type to be HAN_KATA' do
        expect(Moji.type('ﾗ')).to eq Moji::HAN_KATA
        expect(Moji.type?('ﾗ', Moji::ZEN)).to be false
        expect(Moji.type?('ﾗ', Moji::HAN)).to be true
        expect(Moji.type?('ﾗ', Moji::HAN_KATA)).to be true
        expect(Moji.type?('ﾗ', Moji::KANJI)).to be false
      end
    end

    context 'when kanji' do
      let(:str) { '本' }
      let(:exp) { [Moji::KANJI] }

      it 'maps the types' do
        expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
      end

      it 'considers type to be HAN_KATA' do
        expect(Moji.type('本')).to eq Moji::KANJI
        expect(Moji.type?('本', Moji::ZEN)).to be true
        expect(Moji.type?('本', Moji::ZEN_KATA)).to be false
        expect(Moji.type?('本', Moji::HAN)).to be false
        expect(Moji.type?('本', Moji::KANJI)).to be true
      end
    end

    context 'when Arabic' do
      let(:str) { 'مرحبًا' }
      let(:exp) { [nil] * 6 }

      it 'maps the types' do
        expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
      end

      it 'considers type nil' do
        expect(Moji.type('ر')).to be_nil
        expect(Moji.type?('ر', Moji::ZEN)).to be false
      end
    end

    context 'when Thai' do
      let(:str) { 'สวัสดี' }
      let(:exp) { [nil] * 6 }

      it 'maps the types' do
        expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
      end

      it 'considers type nil' do
        expect(Moji.type('ส')).to be_nil
        expect(Moji.type?('ส', Moji::ZEN)).to be false
      end
    end

    context 'when Greek' do
      let(:str) { 'Γειάσου' }
      let(:exp) { [nil] * 7 }

      it 'maps the types' do
        expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
      end

      it 'considers type nil' do
        expect(Moji.type('ε')).to be_nil
        expect(Moji.type?('ε', Moji::ZEN)).to be false
      end
    end

    context 'when Cyrillic' do
      let(:str) { 'Привет' }
      let(:exp) { [nil] * 6 }

      it 'maps the types' do
        expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
      end

      it 'considers type nil' do
        expect(Moji.type('и')).to be_nil
        expect(Moji.type?('и', Moji::ZEN)).to be false
      end
    end

    context 'when Vietnamese' do
      let(:str) { 'Ônài' }
      let(:exp) { [nil, Moji::HAN_LOWER, Moji::HAN_LOWER, nil, Moji::HAN_LOWER] }

      it 'maps the types' do
        expect(str.each_char.map { |chr| described_class.type(chr) }).to eq exp
      end
    end
  end
end
