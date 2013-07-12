#encoding: utf-8
class User < ActiveRecord::Base
  has_many :personal_skills

  attr_accessible :user_id, :level, :name, :position

  def save_value property, value
    method_name = (property.to_s + '=').to_sym
    self.send method_name, value
    self.save
  end

  def new_user name
    save_value :name, name
    save_value :level, 1
    clear_position
  end

  def get_skills
    PersonalSkill.where(:user_id => self.user_id)
  end

  def learn_skill skill_name
    message = "学习技能失败\n技能不存在或者你已经学会此技能"
    if PersonalSkill.where(:user_id => self.user_id, :name => skill_name).empty? && !Skill.where(:name => skill_name).empty?
      PersonalSkill.create(:user_id => self.user_id, :name => skill_name, :level => 1, :exp => 0)
      message = "你成功学会了技能：#{skill_name}"
    end
    clear_position
    message
  end

  def clear_position
    save_value :position, ''
  end

  def at? position
    self.position == position
  end

  def exp_skill skill_name, exp
    skill = PersonalSkill.where(:user_id => self.user_id, :name => skill_name).first
    skill.receive_exp exp
  end
end
