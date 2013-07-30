#encoding: utf-8
class SysStat
  REGISTER = '注册'
  LEARN_SKILL = '学习技能'
  INTRO_SKILL = '介绍技能'
  GO_OUT = '出城'
  BUY = '买'
  SELL = '卖'
  ACTION = '行动'

  def self.register
    REGISTER
  end

  def self.learn_skill
    LEARN_SKILL
  end

  def self.intro_skill
    INTRO_SKILL
  end

  def self.go_out
    GO_OUT
  end

  def self.buy
    BUY
  end

  def self.sell
    SELL
  end

  def self.action
    ACTION
  end
end