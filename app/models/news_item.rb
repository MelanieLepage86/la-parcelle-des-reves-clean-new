class NewsItem < ApplicationRecord
  has_many_attached :photos

  validates :title, :date, :category, presence: true

  enum category: {
    upcoming_event: 'upcoming_event',
    past_event: 'past_event',
    press: 'press'
  }

  def self.grouped_for_display
    {
      upcoming_events: where(category: :upcoming_event).order(date: :asc),
      past_events: where(category: :past_event).order(date: :desc),
      press: where(category: :press).order(date: :desc)
    }
  end
end
