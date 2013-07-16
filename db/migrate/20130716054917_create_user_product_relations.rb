class CreateUserProductRelations < ActiveRecord::Migration
  def change
    create_table :user_product_relations do |t|
      t.integer :user_id
      t.integer :product_id
      t.integer :amount
      t.integer :price

      t.timestamps
    end
  end
end
