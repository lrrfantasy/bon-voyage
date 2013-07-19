class City < ActiveRecord::Base
  has_many :users
  has_many :city_product_relations
  has_many :products, :through => :city_product_relations
  attr_accessible :latitude, :longitude, :name

  def get_dist(city)
    dest_city = City.where(:name => city).first
    (Math.sqrt((self.latitude - dest_city.latitude)**2 + (self.longitude - dest_city.longitude)**2) * 200).to_i
  end

  def sell_price(product)
    product_in_city = self.city_product_relations.where(:product_id => product.id).first
    price = product_in_city.base_price
    has_product = product_in_city.base_amount > 0
    price = (price / 2).to_i if has_product
    price
  end
end
