module Snaps
  class Tag < ActiveRecord::Base

    before_save do |tag|
      Tag.with_name(tag.tag).where(record_perma_id: tag.record_perma_id).current.supersede!
    end

    scope :for_all_revisions_of, ->(record) do
      where(record_perma_id: record.perma_id, record_type: record.class.table_name)
    end

    scope :current, -> do
      where(succeeded_at: nil)
    end

    scope :with_name, ->(name) do
      where(tag: name)
    end

    def self.supersede!
      update_all(succeeded_at: Time.now)
    end

    def self.join_to_model(model, tag, options)
      query = model.joins(<<-SQL)
        INNER JOIN snaps_tags
        ON #{model.table_name}.id = snaps_tags.record_id
        AND snaps_tags.record_type = '#{model.table_name}'
        AND snaps_tags.tag = '#{tag}'
      SQL

      if options[:all_revisions]
        query
      else
        query.where('snaps_tags.succeeded_at IS NULL')
      end
    end
  end
end
