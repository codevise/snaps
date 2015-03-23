module Snaps
  class Snapshot < Struct.new(:record, :options)
    def self.create(record, options, &block)
      new(record, options).create(&block)
    end

    def create
      copy = record.dup
      yield(copy) if block_given?
      copy.save

      copy.snaps_tag!(options[:tag]) if options[:tag]

      snapshot_components(copy)

      copy
    end

    private

    def snapshot_components(copy)
      each_component_with_foreign_key do |component, fk|
        component.snapshot! do |snapshot|
          snapshot[fk] = copy.id
        end
      end
    end

    def each_component_with_foreign_key
      options.fetch(:components, []).each do |association|
        fk = record.class.reflect_on_association(association).foreign_key

        record.send(association).each do |component|
          yield(component, fk)
        end
      end
    end
  end
end
