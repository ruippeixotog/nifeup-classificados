class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :ad
  has_many :reports
end
