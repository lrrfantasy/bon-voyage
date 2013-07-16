class Product < ActiveRecord::Base
  has_many :city_product_relations
  has_many :cities, :through => :city_product_relations

  has_many :user_product_relations
  has_many :users, :through => :user_product_relations
  attr_accessible :category, :name
end
