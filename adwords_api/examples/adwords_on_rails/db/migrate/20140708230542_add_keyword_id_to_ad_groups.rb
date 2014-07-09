class AddKeywordIdToAdGroups < ActiveRecord::Migration
  def change
    add_column :ad_groups, :keyword_id, :integer
  end
end
