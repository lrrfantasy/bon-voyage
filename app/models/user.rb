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

  def learn_skill? skill_name
    successful = false
    if PersonalSkill.where(:user_id => self.user_id, :name => skill_name).empty? && Skill.where(:name => skill_name)
      PersonalSkill.create(:user_id => self.user_id, :name => skill_name, :level => 1)
      successful = true
    end
    clear_position
    successful
  end

  def clear_position
    save_value :position, ''
  end
end
