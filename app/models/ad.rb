class Ad < ActiveRecord::Base
  belongs_to :user
  belongs_to :section
  belongs_to :final_evaluation
  has_many :resources
  has_many :favorites
  has_many :ad_tags
  has_many :users, :through => :favorites
  has_many :evaluations
  has_many :raters, :through => :evaluations, :source => :users

  has_attached_file :thumbnail, :styles => { :medium => "200x200" }

  def open?
    self.closed == 0
  end
  
  def favorite?(user_id)
    not self.users.where("user_id = ?", user_id).empty?
  end
  
  def mark_favorite(user_id)
    fav = Favorite.new :user_id => user_id, :ad_id => self.id
    fav.save
  end
  
  def unmark_favorite(user_id)
    fav = Favorite.find_by_user_id_and_ad_id(user_id, self.id)
    fav.destroy
  end
  
  def rate!(user_id,value)
    evaluation = Evaluation.find_or_create_by_user_id_and_ad_id :user_id => user_id, :ad_id => self.id
    evaluation.value = value
    evaluation.save
    self.calc_average_rating!(user_id,value)
  end
  
  def user_rating(user_id)
    evaluation = Evaluation.find_by_user_id_and_ad_id(user_id, self.id)
    if evaluation != nil
      evaluation.value
    else
      0
    end
  end
  
  def relevance
    self.created_at.to_i
  end
  
  def self.all_opened
    Ad.where(:closed => false)
  end
  
  def self.most_relevant(count)
    return nil if count.nil? || count < 0
    return [] if count == 0
    all_opened.sort_by { |a| -a.relevance }.first(count)
  end
  
  def calc_average_rating!(user_id,value)
      @total = self.evaluations.size
      if self.average_rate == nil
        self.average_rate = value
        self.save
      else
        @old_average = self.average_rate * (@total - 1)
        self.average_rate = (value + @old_average)/@total
        self.save     
      end
  end
  
  def gallery
    #self.resources.where('resources.link_content_type LIKE ?', 'image/%')
    gallery = []
    (0..4).each { gallery.concat(self.resources.where('resources.link_content_type LIKE ?', 'image/%')) } 
    return gallery
  end

end
