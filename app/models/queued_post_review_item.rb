# frozen_string_literal: true
class QueuedPostReviewItem < ReviewItem
  def initialize(item, guardian: nil, queued_at: nil)
    super('QueuedPost', item, guardian: guardian, queued_at: queued_at)
  end

  def actions
    [:approve, :reject, :delete_user]
  end
end
