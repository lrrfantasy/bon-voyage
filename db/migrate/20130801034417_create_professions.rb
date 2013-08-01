class CreateProfessions < ActiveRecord::Migration
  def change
    create_table :professions do |t|
      t.string :name
      t.integer :fee

      t.timestamps
    end
  end
end
