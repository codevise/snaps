# Snaps

[![Gem Version](https://badge.fury.io/rb/snaps.svg)](http://badge.fury.io/rb/snaps)
[![Build Status](https://travis-ci.org/codevise/snaps.svg?branch=master)](https://travis-ci.org/codevise/snaps)
[![Test Coverage](https://codeclimate.com/github/codevise/snaps/badges/coverage.svg)](https://codeclimate.com/github/codevise/snaps)
[![Code Climate](https://codeclimate.com/github/codevise/snaps/badges/gpa.svg)](https://codeclimate.com/github/codevise/snaps)

Revisioning and tagging of ActiveRecord models.

## Installation

Add this line to your application's Gemfile:

    gem 'snaps'

And then execute:

    $ bundle

Run the install generator:

    $ rake snaps:install:migrations

Migrate your database to create the `snaps_tags` table:

    $ rake db:migrate

## Basics

Snaps maintains a table of "named pointers" called Tags to other models. Implemented as a polimorphic association. Revisions are kept in the original table and identified by a `perma_id` field.

Snaps provides methods to create copies (snapshots) of models and tag these snapshots as needed.

## Usage Examples

### Basic Usage

A model that is to be revisioned with snaps needs an integer field called `perma_id` and must include the mixin created by `Snaps.revision`.

    # db/migrate/xxx_create_posts.rb
    create_table :posts do |t|
      t.integer(:perma_id)

      t.string(:title)
      t.text(:body)
    end


    # app/models/post.rb
    class Post < ActiveRecord::Base
      include Snaps.revision
    end


Now you can create snapshots of your post instances.

    post = Posts.create(body: 'Some text')
    post_snapshot = post.snapshot!

    post.perma_id == post_snapshot.perma_id # => true

Using Snaps Tags you can assign one revision to be a 'draft'.

    post.perma_id # => 25
    post.snaps_tag!(:draft)

    draft = Post.with_snaps_tag(:draft).find_by_perma_id(25)

### Using a default Tag

It's easy to create a workflow in which a new post will be tagged by default.
Also it's convenient to hide calls to `with_snaps_tag` in a scope on your domain models.


    # app/models/post.rb
    class Post < ActiveRecord::Base
      include Snaps.revision(default_tag: :draft)

      scope :drafts, -> { with_snaps_tag(:draft) }
    end

    # in controller
    draft = Post.create(body: 'Some Text')

    existing_draft = Post.drafts.find_by_perma_id(25)

    draft.update(body: "New text")
    draft.snapshot!

### Managing Lifecycle of records with tags

    # app/models/post.rb
    class Post < ActiveRecord::Base
      include Snaps.revision(default_tag: :draft)

      scope :drafts, -> { with_snaps_tag(:draft) }
      scope :published, -> { with_snaps_tag(:published) }

      def publish
        snapshot!(tag: :published)
      end
    end

    # in controller
    draft = Post.drafts.find_by_perma_id(25)
    draft.publish

    all_published_posts = Post.published

### Revisioning composite models


    # db/migrate/xxx_create_sections.rb
    create_table :sections do |t|
      t.integer(:perma_id)
      t.references(:post)

      t.text(:body)
    end

    # app/models/section.rb
    class Section < ActiveRecord::Base
      include Snaps.revision

      belongs_to :post
    end

    # app/models/post.rb
    class Post < ActiveRecord::Base
      include Snaps.revision(default_tag: :draft,
                             components: [:sections])

      has_many :sections

      scope :drafts, -> { with_snaps_tag(:draft) }
      scope :published, -> { with_snaps_tag(:published) }

      def publish
        snapshot!(tag: :published)
      end
    end

    # in controller

    draft = Post.drafts.find_by_perma_id(25)
    draft.sections.create(body: "Section text")
    post = draft.snapshot!

    # snapshots of sections have been created

    draft.sections.first.id != post.sections.first.id
    draft.sections.first.body == post.sections.first.body


### Accessing other revisions of a record

    post.snaps_revisions.where('created_at < ?', post.created_at)
