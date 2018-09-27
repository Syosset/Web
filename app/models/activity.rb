class Activity
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Search
  include Mongoid::History::Trackable
  include Publishable
  include Summarizable
  include Linkable
  include Announceable
  include Rankable
  include Subscribable
  include Collaboratable

  slug :name
  paginates_per 12
  search_in :name
  track_history on: [:fields]

  validates :type, inclusion: { in: %w[club group sport],
                                message: '%{value} must be a club, group, or sport' }
  field :type, type: String
end
