class Ad < ActiveRecord::Base
  belongs_to :user
  belongs_to :section
  has_many :resources
end
