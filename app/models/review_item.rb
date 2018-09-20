# frozen_string_literal: true
class ReviewItem
  include ActiveModel::Serialization

  attr_accessor :type, :item, :queued_at

  def initialize(type, item, guardian: nil, queued_at: nil)
    @type = type
    @item = item
    @guardian = guardian
    @queued_at = queued_at
  end

end
