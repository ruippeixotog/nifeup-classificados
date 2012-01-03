class User < ActiveRecord::Base
  has_many :block_log
  has_many :ads
  has_many :favorites
  has_many :favorite_ads, :through => :favorites, :source => :ad
  has_many :evaluations
  has_many :rated_ads, :through => :evaluations, :source => :ads
  
  self.per_page = 20 
  
  @@BLOCK_DURATION = {:week => 7, :twoweeks => 15, :month => 30}
  
  def self.block_durations
    @@BLOCK_DURATION
  end
  
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
  
  def self.search_text(text, page)
    return User.paginate(:page => page) if text.nil? || text.empty?
    
    query = User.search(:username_contains_any => text.split)
    return query.paginate(:page => page)
  end

  def make_admin!
    self.admin = true
    self.save
  end
  
  def make_regular!
    self.admin = false
    self.save
  end
  
  def calc_average_rating!(value)
    # puts self.username
    if self.rate.nil?
      self.rate = value
    else
      rate_count = self.ads.joins('JOIN final_evaluations ON ads.final_evaluation_id = final_evaluations.id').size
      old_rate = self.rate * (rate_count - 1)
      self.rate = (value + old_rate) / rate_count
    end
    self.save
  end
end
