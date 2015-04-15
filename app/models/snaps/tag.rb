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
      model.joins(join_tags_sql('LEFT', model, tag)).where("#{table_alias(tag)}.tag IS NULL")
    end

    def self.all_revisions_with_tag(model, tag)
      model.joins(join_tags_sql('INNER', model, tag))
    end

    def self.current_revisions_with_tag(model, tag)
      all_revisions_with_tag(model, tag).where("#{table_alias(tag)}.superseded_at IS NULL")
    end

    private

    def self.join_tags_sql(type, model, tag)
      table = table_alias(tag)
      (<<-SQL)
        #{type} JOIN snaps_tags #{table}
        ON #{model.table_name}.id = #{table}.record_id
        AND #{table}.record_type = '#{model.name}'
        AND #{table}.tag = '#{tag}'
      SQL
    end

    def self.table_alias(tag)
      @table_aliases ||= Hash.new {|h, t| h[t] = "t_#{t}" }
      @table_aliases[tag]
    end
  end
end
