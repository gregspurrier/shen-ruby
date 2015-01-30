require 'spec_helper'

describe 'Shen -> Ruby interop', :type => :functional do
  describe 'dereferencing constants' do
    it 'supports classes' do
      expect_shen('rb.#String').to eq(String)
    end

    it 'supports modules' do
      expect_shen('rb.#Math').to eq(Math)
    end

    it 'supports constants' do
      expect_shen('rb.#RUBY_VERSION').to eq(RUBY_VERSION)
    end

    it 'supports nested lookup' do
      expect_shen('rb.#Math#PI').to eq(Math::PI)
    end
  end

  describe 'method invocation' do
    describe 'instance methods' do
      it 'invokes the named method on an object' do
        expect_shen('(rb.reverse "abc")').to eq("cba")
      end

      it 'passes additional arguments to the method' do
        expect_shen('(rb.prepend "bar" "foo")').to eq("foobar")
      end

      it 'supports [] and []= via rb.<- and rb.->' do
        expect_shen(<<-EOSHEN).to eq('ruby')
          (let Hash (rb.new rb.#Hash)
            (do (rb.-> Hash "hello" "ruby")
                (rb.<- Hash "hello")))
        EOSHEN
      end

      it 'provides sugar for hash parameters in final position' do
        expect_shen(<<-EOSHEN).to eq('hello ruby')
          (let Hash (rb.<- rb.#Hash key1 => "hello" key2 =>"ruby")
            (@s (rb.<- Hash key1) " " (rb.<- Hash key2)))
        EOSHEN
      end
    end

    describe 'class method invocation' do
      it 'is supported by a sugared syntax' do
        expect_shen('(rb.#Math.sqrt 4)').to eq(2)
      end
    end

    describe 'kernel method invocation' do
      it 'is supported by a sugared syntax' do
        expect_shen('(rb.#sprintf "%0.3f" 0.1)').to eq('0.100')
      end
    end

    describe 'the optional block argument' do
      it 'accepts abstractions' do
        expect_shen('(rb.find [1 2 3] & (/. X (> X 1)))').to eq(2)
      end

      it 'accepts naked function names' do
        expect_shen('(rb.find [1 "abc" foo] & string?)').to eq("abc")
      end

      it 'accepts wrapped function names' do
        expect_shen('(rb.find [1 "abc" foo] & (function string?))').to eq("abc")
      end

      it 'supports arities other than 1' do
        expect_shen('(rb.reduce [1 2 3] &2 (/. A X (+ A X)))').to eq(6)
        expect_shen('(rb.reduce [1 2 3] &2 +)').to eq(6)
        expect_shen('(rb.reduce [1 2 3] &2 (function +))').to eq(6)
      end
    end
  end
end
