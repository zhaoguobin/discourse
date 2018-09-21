class AddEnhancedPrivacyToUserOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_options, :enhanced_privacy, :boolean, default: false, null: false
  end
end
