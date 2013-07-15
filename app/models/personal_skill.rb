#encoding: utf-8
class PersonalSkill < ActiveRecord::Base
  attr_accessible :level, :name, :user_id, :exp

  def receive_exp exp
    message = "#{self.name}获得经验#{exp}\n"
    self.exp += exp.to_i
    while self.exp >= self.level**2 * 100
      self.exp -= self.level**2 * 100
      self.level += 1
      message += "#{self.name}升到了Lv.#{self.level}\n"
    end
    self.save
    message
  end
end
