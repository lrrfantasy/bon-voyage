class CreateSpecialities < ActiveRecord::Migration
  def change
    create_table :specialities do |t|
      t.integer :profession_id
      t.integer :skill_id

      t.timestamps
    end
  end
end
