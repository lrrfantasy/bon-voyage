class UserProductRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  attr_accessible :amount, :price, :product_id, :user_id
end
