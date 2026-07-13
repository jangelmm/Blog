class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string  :title,      null: false
      t.string  :slug,       null: false
      t.text    :description
      t.text    :body
      t.string  :tech_stack   # separado por comas, ej: "Python, C++, CUDA"
      t.string  :icon         # clase Font Awesome de respaldo si no hay imagen
      t.integer :position, default: 0

      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end
