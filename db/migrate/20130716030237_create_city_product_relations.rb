class CreateCityProductRelations < ActiveRecord::Migration
  def change
    create_table :city_product_relations do |t|
      t.integer :city_id
      t.integer :product_id
      t.integer :base_amount
      t.integer :base_price

      t.timestamps
    end
  end
end
