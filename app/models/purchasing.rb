class Purchasing < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  attr_accessible :amount, :product_id, :user_id
end
