#encoding: utf-8
class PersonalAction < ActiveRecord::Base
  attr_accessible :from, :last_time, :start_time, :status, :to, :user_id

  def move_city from, to, start_time, last_time
    self.status = "移动"
    self.from = from
    self.to = to
    self.start_time = start_time
    self.last_time = last_time.to_s
    self.save

    user = User.where(:user_id => self.user_id).first
    user.save_value :sys_stat, '行动'
  end
end
