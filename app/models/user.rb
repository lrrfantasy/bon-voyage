#encoding: utf-8
class User < ActiveRecord::Base
  has_many :personal_skills

  attr_accessible :user_id, :level, :name, :sys_stat, :position

  def save_value property, value
    method_name = (property.to_s + '=').to_sym
    self.send method_name, value
    self.save
  end

  def new_user name
    save_value :name, name
    save_value :level, 1
    save_value :position, '成都'
    clear_sys_stat
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
    clear_sys_stat
    message
  end

  def clear_sys_stat
    save_value :sys_stat, ''
  end

  def at? sys_stat
    self.sys_stat == sys_stat
  end

  def exp_skill skill_name, exp
    skill = PersonalSkill.where(:user_id => self.user_id, :name => skill_name).first
    skill.receive_exp exp
  end

  def get_stat
    "姓名：#{self.name}\n" +
        "等级：#{self.level.to_s}\n" +
        "位置：#{self.position}"
  end

  def go_to city
    message = ''
    if city == self.position
      message += "你已经在#{city}"
    elsif City.where(:name => city).empty?
      message += '没有找到该城市'
    else
      distance = City.where(:name => self.position).first.get_dist city
      message += "从#{self.position}到#{city}有#{distance}里\n"
      save_value :position, city
      message += "你已移动至#{city}"
    end
    clear_sys_stat
    message
  end
end
