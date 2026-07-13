# db/migrate/XXXXXX_rename_tag_to_path_on_posts.rb
class RenameTagToPathOnPosts < ActiveRecord::Migration[7.1]
  def change
    rename_column :posts, :tag, :path
    add_index :posts, :path
  end
end
