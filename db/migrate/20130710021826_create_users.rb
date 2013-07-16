class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_wechat_id
      t.string :name
      t.integer :level
      t.string :sys_stat
      t.string :position
      t.integer :money

      t.timestamps
    end
  end
end
