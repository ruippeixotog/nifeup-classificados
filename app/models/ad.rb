class Ad < ActiveRecord::Base
  belongs_to :user
  belongs_to :section
  has_many :resources
  has_and_belongs_to_many :users
  
  has_attached_file :thumbnail, :styles => { :thumb => "140x180>" }
end
