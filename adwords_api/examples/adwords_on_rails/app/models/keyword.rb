class Keyword < ActiveRecord::Base
  belongs_to :ad_group
  attr_accessible :location, :type, :value
end
