class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :value
      t.string :type
      t.boolean :location

      t.timestamps
    end
  end
end
