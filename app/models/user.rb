class User < ActiveRecord::Base
  has_many :block_log
  has_many :ads
  has_and_belongs_to_many :favorites, :class_name => "Ad"
end
