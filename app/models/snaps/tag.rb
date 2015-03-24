module Snaps
  class Tag < ActiveRecord::Base
    belongs_to :record, polymorphic: true

    before_save do |tag|
      Tag.join_model(tag.record.class, tag.tag).where("perma_id = ?", tag.record.perma_id).current.supersede!
    end

    scope :current, -> do
      where(superseded_at: nil)
    end

    scope :with_name, ->(name) do
      where(tag: name)
    end

    def self.supersede!
      update_all(superseded_at: Time.now)
    end

    def self.join_model(model, tag)
      joins(<<-SQL)
        INNER JOIN #{model.table_name}
        ON #{model.table_name}.id = snaps_tags.record_id
        AND snaps_tags.record_type = '#{model.name}'
        AND snaps_tags.tag = '#{tag}'
      SQL
    end

    def self.join_to_model(model, tag, options = {})
      query = model.joins(<<-SQL)
        INNER JOIN snaps_tags
        ON #{model.table_name}.id = snaps_tags.record_id
        AND snaps_tags.record_type = '#{model.name}'
        AND snaps_tags.tag = '#{tag}'
      SQL

      if options[:all_revisions]
        query
      else
        query.where('snaps_tags.superseded_at IS NULL')
      end
    end
  end
end
