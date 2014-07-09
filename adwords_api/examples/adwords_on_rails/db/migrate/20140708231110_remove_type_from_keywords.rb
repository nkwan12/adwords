class RemoveTypeFromKeywords < ActiveRecord::Migration
  def up
	remove_column :keywords, :type
  end

  def down
  end
end
