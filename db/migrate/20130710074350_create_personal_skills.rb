class CreatePersonalSkills < ActiveRecord::Migration
  def change
    create_table :personal_skills do |t|
      t.string :name
      t.integer :level
      t.string :user_id
      t.integer :exp

      t.timestamps
    end
  end
end
