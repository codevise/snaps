# This migration comes from snaps (originally 20150321131740)
class CreateSnapsTags < ActiveRecord::Migration
  def change
    create_table :snaps_tags do |t|
      t.integer :record_id
      t.string :record_type
      t.string :tag
      t.timestamp :superseded_at

      t.timestamps null: false
    end
  end
end
