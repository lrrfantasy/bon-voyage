class CreatePersonalSkills < ActiveRecord::Migration
  def change
    create_table :personal_skills do |t|
      t.integer :user_id
      t.string :name
      t.integer :level
      t.integer :exp

      t.timestamps
    end
  end
end
