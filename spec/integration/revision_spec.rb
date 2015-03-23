require 'spec_helper'

describe "Snaps.revision" do
  it "ensures a perma_id" do
    post = create(:post)
    expect(post.perma_id).to be_present

    post2 = create(:post)
    expect(post2.perma_id).to(be > post.perma_id)
  end

  it "creates a default tag when a new revisioned record is created" do
    post = create(:post)

    tag = Snaps::Tag.find_by(record_perma_id: post.perma_id)

    expect(tag.tag).to eq("draft")
  end

  describe '#snapshot!' do
    it "creates new record" do
      post = create(:post, title: 'ein titel')
      post.snapshot!
      expect(Post.all.length).to eq(2)

      new_post = Post.last

      expect(post.perma_id).to eq(new_post.perma_id)
      expect(post.id).not_to eq(new_post.id)
      expect(new_post.title).to eq(post.title)
    end

    it 'yields unsaved record' do
      post = create(:post, title: 'ein titel')

      is_new_record = :not_called

      snapshot = post.snapshot! do |s|
        is_new_record = s.new_record?
        s.title = 'zwei titel'
      end

      expect(is_new_record).to be(true)
      expect(snapshot.reload.title).to eq('zwei titel')

    end

    it 'can tag the new record' do
      post = create(:post, title: 'ein titel')
      post_snapshot = post.snapshot!(tag: :published)

      expect(Post.with_snaps_tag(:published).first).to eq(post_snapshot)
    end

    it 'snapshots the components of the record' do
      post = create(:post_with_sections, title: 'ein titel')
      section = post.sections.create!(title: 'section')

      post_snapshot = post.snapshot!

      expect(post_snapshot.sections.length).to eq(1)
      expect(post_snapshot.sections.first.title).to eq(section.title)
      expect(post_snapshot.sections.first.id).not_to eq(section.id)
    end

  end

  describe '#snaps_tag!' do
    it "creates new record in snaps_tags" do
      post = create(:post)
      tag = post.snaps_tag!(:published)

      expect(tag.record_perma_id).to eq(post.perma_id)
      expect(tag.tag).to eq("published")
    end

    it "supersedes record tagged previousy with the same tag" do
      post = create(:post)
      new_post = post.snapshot!
      tag = post.snaps_tag!(:published)
      new_post.snaps_tag!(:published)

      tag.reload

      expect(tag.succeeded_at).to be_present
    end

    it 'does not supersede tags with different tagnames' do
      post = create(:post)
      new_post = post.snapshot!
      tag = post.snaps_tag!(:published)
      new_post.snaps_tag!(:foo)

      tag.reload

      expect(tag.succeeded_at).to be_blank
    end

    it 'does not change already superseded tags' do
      post = create(:post)
      superseded_tag = post.snaps_tag!(:published)

      post_snapshot = post.snapshot!
      post_snapshot.snaps_tag!(:published)

      Timecop.freeze 2.weeks.from_now do
        post_snapshot = post.snapshot!
        post_snapshot.snaps_tag!(:published)

        superseded_tag.reload

        expect(superseded_tag.succeeded_at).to eq(2.weeks.ago)
      end
    end
  end

  describe '#snaps_revisions' do
    it 'returns all revisions of record' do
      post = create(:post)
      post_snapshot = post.snapshot!

      result = post.snaps_revisions

      expect(result.length).to eq(2)
      expect(result).to include(post_snapshot)
      expect(result).to include(post)
    end
  end

  describe '.with_snaps_tag' do
    it "returns list of records joined with snaps_tags" do
      post = create(:post)
      post.snaps_tag!(:published)

      expect(Post.with_snaps_tag(:published).length).to eq(1)
    end

    it "does not return records with differnt tags" do
      post = create(:post)
      post.snaps_tag!(:published)

      expect(Post.with_snaps_tag(:other).length).to eq(0)
    end

    it 'does not return untagged records' do
      create(:post)
      expect(Post.with_snaps_tag(:published).length).to eq(0)
    end

    it "only returns current revision of record" do
      post = create(:post)
      post_snapshot = post.snapshot!
      post.snaps_tag!(:published)
      post_snapshot.snaps_tag!(:published)

      expect(Post.with_snaps_tag(:published).length).to eq(1)
      expect(Post.with_snaps_tag(:published).first).to eq(post_snapshot)
    end

    context 'with :all_revisions option' do
      it "returns all revisions of record" do
        post = create(:post)
        post_snapshot = post.snapshot!
        post.snaps_tag!(:published)
        post_snapshot.snaps_tag!(:published)

        result = Post.with_snaps_tag(:published, all_revisions: true)

        expect(result.length).to eq(2)
        expect(result).to include(post_snapshot)
        expect(result).to include(post)
      end
    end
  end
end
