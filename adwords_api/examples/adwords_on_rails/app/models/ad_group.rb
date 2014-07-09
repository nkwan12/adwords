class AdGroup < ActiveRecord::Base
	has_many :keywords
  attr_accessible :name, :url
end
