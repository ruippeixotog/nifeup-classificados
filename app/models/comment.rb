class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :ad
  has_many :reports

  
  
  def self.find_by_ad_id(ad)
    self.where('ad_id LIKE ?', ad)
  end

  @@report_limit = 5

  def self.all_reported
    # TODO get all reported comments
  end

  def self.set_report_limit(limit)
    @@report_limit = limit
  end

  def reported?
    # TODO return true if the comment has been reported
  end

  def report!(user_id, reason)
    # TODO report a comment
  end

  def badly_reported?    
    # TODO return true if the comment has been reported more than @@report_limit
  end
end
