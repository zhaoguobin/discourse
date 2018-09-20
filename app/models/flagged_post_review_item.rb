# frozen_string_literal: true
class FlaggedPostReviewItem < ReviewItem
  def initialize(post, guardian: nil, queued_at: nil)
    super('FlaggedPost', post, guardian: guardian, queued_at: queued_at)
    @user = User.find_by_id(post[:user_id])
  end

  def actions
    list = self.class.common_actions

    if @item[:user_deleted]
      list << :agree_restore_post
    elsif !@item[:hidden]
      list << :agree_hide_post
    end

    if @user &&
      @guardian.can_delete_user?(@user) &&
      @item[:post_actions]&.any? { |a| a[:name_key] == :spam }

      list << :delete_spammer
    end
    list
  end

  def self.common_actions
    [
      :agree_no_change,
      :agree_suspend_user,
      :agree_silence_user,
      :disagree,
      :defer,
      :delete_post_defer,
      :delete_post_agree
    ]
  end
end
