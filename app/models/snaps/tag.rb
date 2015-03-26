module Snaps
  class Tag < ActiveRecord::Base
    include Suppressor

    belongs_to :record, polymorphic: true

    before_save do |tag|
      tag.record.snaps_untag!(tag.tag)
    end

    scope :current, -> do
      where(superseded_at: nil)
    end

    scope :with_name, ->(name) do
      where(tag: name)
    end

    def self.supersede!
      current.update_all(superseded_at: Time.now)
    end

    def self.for_all_revisions_of(record)
      joins(<<-SQL)
        INNER JOIN #{record.class.table_name}
        ON #{record.class.table_name}.id = snaps_tags.record_id
        AND snaps_tags.record_type = '#{record.class.name}'
        AND perma_id = #{record.perma_id}
      SQL
    end

    def self.all_revisions_without_tag(model, tag)
      table_alias = "t_#{tag}"

      query = model.joins(<<-SQL)
        LEFT JOIN snaps_tags #{table_alias}
        ON #{model.table_name}.id = #{table_alias}.record_id
        AND #{table_alias}.record_type = '#{model.name}'
        AND #{table_alias}.tag = '#{tag}'
      SQL
      query.where("#{table_alias}.tag IS NULL")
    end

    def self.all_revisions_with_tag(model, tag)
      table_alias = "t_#{tag}"

      model.joins(<<-SQL)
        INNER JOIN snaps_tags #{table_alias}
        ON #{model.table_name}.id = #{table_alias}.record_id
        AND #{table_alias}.record_type = '#{model.name}'
        AND #{table_alias}.tag = '#{tag}'
      SQL
    end

    def self.current_revisions_with_tag(model, tag)
      all_revisions_with_tag(model, tag).where("t_#{tag}.superseded_at IS NULL")
    end
  end
end
