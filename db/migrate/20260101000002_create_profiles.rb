class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :role
      t.text   :bio
      t.string :quote
      t.string :location_label # ej. "Observatorio Astronómico Nacional · 2024"

      t.timestamps
    end
  end
end
