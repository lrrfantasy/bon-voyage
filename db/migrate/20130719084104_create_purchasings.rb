class CreatePurchasings < ActiveRecord::Migration
  def change
    create_table :purchasings do |t|
      t.integer :user_id
      t.integer :product_id
      t.integer :amount

      t.timestamps
    end
  end
end
