class AddAdGroupIdToKeywords < ActiveRecord::Migration
  def change
    add_column :keywords, :ad_group_id, :integer
  end
end
