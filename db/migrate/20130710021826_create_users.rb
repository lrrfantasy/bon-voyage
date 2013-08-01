class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_wechat_id
      t.string :name
      t.integer :level
      t.string :sys_stat
      t.integer :money
      t.integer :city_id
      t.integer :profession_id
      t.integer :load

      t.timestamps
    end
  end
end
