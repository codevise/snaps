class Section < ActiveRecord::Base
  include Snaps.revision

  belongs_to :post
end
