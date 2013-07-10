class User < ActiveRecord::Base
  attr_accessible :user_id, :level, :name, :position

  def save_value property, value
    method_name = (property.to_s + '=').to_sym
    self.send method_name, value
    self.save
  end
end
