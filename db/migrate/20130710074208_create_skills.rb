class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :name
      t.text :description
      t.integer :max_level

      t.timestamps
    end
  end
end
