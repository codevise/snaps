class Post < ActiveRecord::Base
  include Snaps.revision(default_tag: :draft)
end
