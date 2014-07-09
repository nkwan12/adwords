class AddMatchToKeywords < ActiveRecord::Migration
  def change
    add_column :keywords, :match, :string
  end
end
