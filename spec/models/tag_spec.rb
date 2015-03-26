require 'spec_helper'

describe Snaps::Tag do
  describe '#for_all_revisions_of' do
    it 'retruns a list of Tags for the passed record' do
      post = create(:post, title: 'ein titel')
      tag = post.snaps_tag!(:published)

      tags = Snaps::Tag.for_all_revisions_of(post)

      expect(tags).to include(tag)
    end
  end

  describe '#all_revisions_with_tag' do
    it 'Returns a list of records tagged with the tagname' do
      post = create(:post, title: 'ein titel')
      post_snapshot = post.snapshot!(tag: :published)

      posts = Snaps::Tag.all_revisions_with_tag(Post, :published)

      expect(posts).to include(post_snapshot)
      expect(posts).not_to include(post)
    end
  end

  describe '#all_revisions_without_tag' do
    it 'Returns a list of records not tagged with the tagname' do
      post = create(:post, title: 'Some Titel')
      published_post = post.snapshot!(tag: :published)

      posts = Snaps::Tag.all_revisions_without_tag(Post, :published)

      expect(posts).to include(post)
      expect(posts).not_to include(published_post)
    end
  end
end
