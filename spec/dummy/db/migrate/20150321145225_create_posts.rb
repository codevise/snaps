class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :perma_id
      t.string :title
      t.text :body

      t.timestamps null: false
    end
  end
end
