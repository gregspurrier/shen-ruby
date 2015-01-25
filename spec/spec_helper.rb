require 'shen_ruby'

module EvalShen
  def eval_shen(str)
    @shen.eval_string(str)
  end

  def expect_shen(str)
    expect(eval_shen(str))
  end
end

RSpec.configure do |cfg|
  # Support eval_kl and friends in functional specs
  cfg.include EvalShen, :type => :functional
  cfg.before(:all, :type => :functional) do
    @shen = ShenRuby::Shen.new
  end
end
