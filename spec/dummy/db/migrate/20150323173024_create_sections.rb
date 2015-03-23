class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :post_id
      t.integer :perma_id
      t.string :title

      t.timestamps null: false
    end
  end
end
