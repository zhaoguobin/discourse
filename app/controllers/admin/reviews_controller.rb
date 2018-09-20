require 'flag_query'

class Admin::ReviewsController < Admin::AdminController

  PAGE_SIZE = 10

  def index
    posts, topics, users, _, total_rows = FlagQuery.flagged_posts_report(
      current_user,
      offset: params[:offset].to_i,
      per_page: PAGE_SIZE
    )

    review_items = posts.map do |post|
      FlaggedPostReviewItem.new(
        post,
        guardian: guardian,
        queued_at: post[:post_actions].sort_by { |pa| pa[:created_at] }&.first[:created_at]
      )
    end

    queued_posts = QueuedPost.visible.where(state: QueuedPost.states[:new]).order(:created_at)
    topics += Topic.where(id: queued_posts.map(&:topic_id)).where.not(id: topics.map(&:id)).to_a
    users += User.where(id: queued_posts.map(&:user_id)).where.not(id: users.map(&:id)).to_a

    queued_posts.each do |post|
      review_items << QueuedPostReviewItem.new(post, guardian: guardian, queued_at: post.created_at)
    end

    review_items.sort_by! { |item| item.queued_at }

    render_json_dump(
      reviews: serialize_data(review_items, ReviewItemSerializer),
      topics: serialize_data(topics, FlaggedTopicSerializer),
      users: serialize_data(users, FlaggedUserSerializer)
    )
  end
end
