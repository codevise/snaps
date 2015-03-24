module Snaps
  class Tag < ActiveRecord::Base
    belongs_to :record, polymorphic: true

    before_save do |tag|
      Tag
        .for_all_revisions_of(tag.record)
        .with_name(tag.tag)
        .current
        .supersede!
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

    def self.for_all_revisions_of(record)
      joins(<<-SQL)
        INNER JOIN #{record.class.table_name}
        ON #{record.class.table_name}.id = snaps_tags.record_id
        AND snaps_tags.record_type = '#{record.class.name}'
        AND perma_id = #{record.perma_id}
      SQL
    end

    def self.all_revisions_with_tag(model, tag)
      model.joins(<<-SQL)
        INNER JOIN snaps_tags
        ON #{model.table_name}.id = snaps_tags.record_id
        AND snaps_tags.record_type = '#{model.name}'
        AND snaps_tags.tag = '#{tag}'
      SQL
    end

    def self.current_revisions_with_tag(model, tag)
      all_revisions_with_tag(model, tag).where('snaps_tags.superseded_at IS NULL')
    end
  end
end
