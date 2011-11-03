class User < ActiveRecord::Base
  has_many :block_log
  has_many :ads
  has_many :favorites
  has_many :ads, :through => :favorites
  
  def self.epinto
    user = User.new :username => 'epinto'
    user.id = 1
    user
  end
end
