class CreatePersonalActions < ActiveRecord::Migration
  def change
    create_table :personal_actions do |t|
      t.integer :user_id
      t.string :status
      t.string :from
      t.string :to
      t.string :start_time
      t.string :last_time

      t.timestamps
    end
  end
end
