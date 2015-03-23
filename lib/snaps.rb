require "snaps/engine"
require "snaps/snapshot"

module Snaps
  def self.revision(options={})
    Module.new do
      extend ActiveSupport::Concern

      included do
        before_save :ensure_perma_id
        if options[:default_tag]
          after_create do
            snaps_tag!(options[:default_tag])
          end
        end

      end

      def snapshot!(options = {}, &block)
        Snapshot.create(self,
                        options.merge(self.class.snaps_options),
                        &block)
      end

      def snaps_tag!(tag)
        Tag.create!(
          record: self,
          tag: tag
        )
      end

      def snaps_revisions
         self.class.where(perma_id: perma_id)
      end


      def ensure_perma_id
        self.perma_id ||= (self.class.maximum(:perma_id) || 0) + 1
      end

      class_methods do
        def with_snaps_tag(tag, options={})
          Tag.join_to_model(self, tag, options)
        end

        define_method :snaps_options do
          options
        end
      end
    end
  end
end
