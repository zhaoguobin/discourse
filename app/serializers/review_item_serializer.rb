class ReviewItemSerializer < ActiveModel::Serializer
  attributes :type, :item, :queued_at, :actions
end
