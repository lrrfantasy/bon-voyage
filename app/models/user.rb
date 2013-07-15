#encoding: utf-8
class User < ActiveRecord::Base
  has_one :personal_action
  has_many :personal_skills

  attr_accessible :user_wechat_id, :level, :name, :sys_stat, :position

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
    self.personal_skills
  end

  def learn_skill skill_name
    message = "学习技能失败\n技能不存在或者你已经学会此技能"
    if self.personal_skills.where(:name => skill_name).empty? && !Skill.where(:name => skill_name).empty?
      self.personal_skills.create(:name => skill_name, :level => 1, :exp => 0)
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
    skill = self.personal_skills.where(:name => skill_name).first
    skill.receive_exp exp
  end

  def get_stat
    "姓名：#{self.name}\n" +
        "等级：#{self.level.to_s}\n" +
        "位置：#{self.position}"
  end

  def go_to city, start_time
    message = ''
    if city == self.position
      message += "你已经在#{city}"
      clear_sys_stat
    elsif City.where(:name => city).empty?
      message += '没有找到该城市'
      clear_sys_stat
    else
      distance = City.where(:name => self.position).first.get_dist city
      cost_time = (distance/100).to_i
      message += "从#{self.position}到#{city}有#{distance}里\n"
      message += "需要用时#{cost_time}秒"

      action = self.personal_action
      action.move_city self.position, city, start_time, cost_time
      save_value :sys_stat, '行动'
    end
    message
  end

  def check_action start_time
    message = ''
    action = self.personal_action
    if action.status == '移动'
      if start_time.to_i >= action.start_time.to_i + action.last_time.to_i
        message += "你已移动到#{action.to}"
        save_value :position, action.to
        clear_sys_stat
      else
        remaining_time = action.start_time.to_i + action.last_time.to_i - start_time.to_i
        message += "你正在从#{action.from}到#{action.to}的路上，还要#{remaining_time}秒到达"
      end
    end
    message
  end
end
