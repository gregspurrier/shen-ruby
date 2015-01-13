require 'spec_helper'

describe 'Ruby <-> Shen type converters' do
  before :all do
    @shen = ShenRuby::Shen.new
  end

  def eval_shen(str)
    @shen.eval_string(str)
  end

  def expect_shen(str)
    expect(eval_shen(str))
  end

  describe 'ShenRuby.array_to_list' do
    it 'returns a Shen list containing the elements of the array' do
      @shen.set(:"test-list", ShenRuby.array_to_list([1, 2, 3]))
      expect_shen(<<-EOS).to be true
        (= (value test-list) [1 2 3])
      EOS
    end
  end

  describe 'ShenRuby.list_to_array' do
    it 'returns a Ruby array containing the elements of the list' do
      l = eval_shen('[1 2 3]')
      expect(ShenRuby.list_to_array(l)).to eq([1, 2, 3])
    end
  end

  describe 'ShenRuby.array_to_vector' do
    it 'returns a Shen list containing the elements of the array' do
      @shen.set(:"test-vector", ShenRuby.array_to_vector([1, 2, 3]))
      expect_shen(<<-EOS).to be true
        (= (value test-vector)
           (vector-> (vector-> (vector-> (vector 3) 1 1) 2 2) 3 3))
      EOS
    end
  end

  describe 'ShenRuby.vector_to_array' do
    it 'returns a Ruby array containing the elements of the vector' do
      v = eval_shen('(vector-> (vector-> (vector-> (vector 3) 1 1) 2 2) 3 3)')
      expect(ShenRuby.vector_to_array(v)).to eq([1, 2, 3])
    end
  end
end
