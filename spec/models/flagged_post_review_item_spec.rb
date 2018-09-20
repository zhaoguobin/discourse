require 'rails_helper'

describe FlaggedPostReviewItem do
  let(:admin) { Fabricate(:admin) }
  let(:user) { Fabricate(:user) }
  let(:valid_post_hash) { {
    id: 1215,
    excerpt: "Come to my e-commerce web page.",
    raw: "Come to my e-commerce web page.",
    user_id: user.id,
    topic_id: 506,
    post_number: 3,
    reply_count: 0,
    hidden: false,
    deleted_at: nil,
    user_deleted: false,
    post_actions: [{ id: 153, post_id: 1215, user_id: 1, post_action_type_id: 4, created_at: 1.day.ago, disposed_by_id: nil, disposed_at: nil, disposition: nil, related_post_id: nil, targets_topic: false, staff_took_action: false, name_key: :inappropriate }],
    post_action_ids: nil,
    last_revised_at: nil,
    previous_flags_count: 0
  } }

  ALWAYS_AVAILABLE_RESPONSES = [
    :agree_no_change,
    :agree_suspend_user,
    :agree_silence_user,
    :disagree,
    :defer,
    :delete_post_defer,
    :delete_post_agree
  ]

  def flag_for_spam(post_hash)
    post_hash[:post_actions].first[:post_action_type_id] = PostActionType.types[:spam]
    post_hash[:post_actions].first[:name_key] = :spam
  end

  describe 'actions' do

    subject { FlaggedPostReviewItem.new(
      post_hash,
      guardian: Guardian.new(admin),
      queued_at: 1.hour.ago).actions
    }

    context 'user cannot be deleted' do
      before { Guardian.any_instance.stubs(:can_delete_user?).returns(false) }

      context 'visible post' do
        let(:post_hash) { valid_post_hash }
        it { is_expected.to contain_exactly(*ALWAYS_AVAILABLE_RESPONSES, :agree_hide_post) }
      end

      context 'hidden post' do
        let(:post_hash) { valid_post_hash.merge(hidden: true) }
        it { is_expected.to contain_exactly(*ALWAYS_AVAILABLE_RESPONSES) }
      end

      context 'flagged for spam' do
        let(:post_hash) { valid_post_hash }
        before { flag_for_spam(post_hash) }

        it { is_expected.to contain_exactly(*ALWAYS_AVAILABLE_RESPONSES, :agree_hide_post) }
      end

      context 'post is user_deleted' do
        let(:post_hash) { valid_post_hash.merge(user_deleted: true) }
        it { is_expected.to contain_exactly(*ALWAYS_AVAILABLE_RESPONSES, :agree_restore_post) }
      end
    end

    context 'user can be deleted' do
      before { Guardian.any_instance.stubs(:can_delete_user?).returns(true) }

      context 'flagged for spam' do
        let(:post_hash) { valid_post_hash }
        before { flag_for_spam(post_hash) }

        it { is_expected.to contain_exactly(
            *ALWAYS_AVAILABLE_RESPONSES,
            :agree_hide_post,
            :delete_spammer
          )
        }
      end

      context 'visible post' do
        let(:post_hash) { valid_post_hash }
        it { is_expected.to contain_exactly(*ALWAYS_AVAILABLE_RESPONSES, :agree_hide_post) }
      end

      context 'hidden post' do
        let(:post_hash) { valid_post_hash.merge(hidden: true) }
        it { is_expected.to contain_exactly(*ALWAYS_AVAILABLE_RESPONSES) }
      end

      context 'post is user_deleted' do
        let(:post_hash) { valid_post_hash.merge(user_deleted: true) }
        before { flag_for_spam(post_hash) }
        it { is_expected.to contain_exactly(
            *ALWAYS_AVAILABLE_RESPONSES,
            :agree_restore_post,
            :delete_spammer
          )
        }
      end
    end
  end
end
