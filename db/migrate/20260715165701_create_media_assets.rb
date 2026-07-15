class CreateMediaAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :media_assets do |t|
      t.string :path

      t.timestamps
    end
  end
end
