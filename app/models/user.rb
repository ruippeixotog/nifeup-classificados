class User < ActiveRecord::Base
  has_many :block_log
  has_many :ads
  has_many :favorites
  has_many :ads, :through => :favorites
  has_many :evaluations
  has_many :rated_ads, :through => :evaluations, :source => :ads
  
  def self.epinto
    user = User.new :username => 'epinto'
    user.id = 1
    user
  end
  
  def self.search_for_uname uname
    if key
      find(:all, :conditions => ['login LIKE ?', "%#{uname}%"])
    else
      find(:all)
    end
  end

end
