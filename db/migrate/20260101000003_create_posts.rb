class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string   :title,        null: false
      t.string   :slug,         null: false
      t.text     :description
      t.text     :body
      t.string   :tag
      t.boolean  :published, default: true, null: false
      t.datetime :published_at

      t.timestamps
    end
    add_index :posts, :slug, unique: true
  end
end
