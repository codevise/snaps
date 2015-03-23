class PostWithSections < ActiveRecord::Base
  self.table_name = "posts"

  include Snaps.revision(default_tag: :draft, components: [:sections])

  has_many :sections, foreign_key: :post_id
end
