class CreateSnapsTags < ActiveRecord::Migration
  def change
    create_table :snaps_tags do |t|
      t.integer :record_id
      t.string :record_type
      t.integer :record_perma_id
      t.string :tag
      t.timestamp :succeeded_at

      t.timestamps null: false
    end
  end
end
