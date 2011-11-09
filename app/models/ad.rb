class Ad < ActiveRecord::Base
  belongs_to :user
  belongs_to :section
  has_many :resources
  has_many :favorites
  has_many :ad_tags
  has_many :users, :through => :favorites
  has_many :evaluations
  has_many :raters, :through => :evaluations, :source => :users

  has_attached_file :thumbnail, :styles => { :thumb => "140x180>", :medium => "250x250>" }
  
  def self.all_opened
    Ad.where(:closed => false)
  end
  
  def self.most_relevant(count)
    return nil if count.nil? || count < 0
    return [] if count == 0
    order_by_relevance(all_opened).first(count)
  end
  
  def self.search_text(text, limit=2**29)
    return [] if limit.nil? || limit <= 0
    return most_relevant(limit) if text.nil? || text.empty?
    search = all_opened.search(:title_or_ad_tags_tag_contains_any => text.split).all
    order_by_relevance(search.uniq).first(limit)
  end

  def open?
    self.closed == 0
  end
  
  def favorite?(user_id)
    not self.users.where("user_id = ?", user_id).empty?
  end
  
  def mark_favorite!(user_id)
    fav = Favorite.new :user_id => user_id, :ad_id => self.id
    fav.save
  end
  
  def unmark_favorite!(user_id)
    fav = Favorite.find_by_user_id_and_ad_id(user_id, self.id)
    fav.destroy
  end
  
  def rate(user_id,value)
    evaluation = Evaluation.find_or_create_by_user_id_and_ad_id :user_id => user_id, :ad_id => self.id
    evaluation.value = value
    evaluation.save 
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
    # TODO better algorithm!
    self.created_at.to_i
  end
  
  def average_rating
      @value = 0
      self.evaluations.each do |evaluation|
          @value = @value + evaluation.value
      end
      @total = self.evaluations.size
      if @total > 0
        @value.to_f / @total.to_f
      else
        "Not yet rated"
      end
  end
  
  def gallery
    #self.resources.where('resources.link_content_type LIKE ?', 'image/%')
    gallery = []
    (0..4).each { gallery.concat(self.resources.where('resources.link_content_type LIKE ?', 'image/%')) } 
    return gallery
  end
  
private
  def self.order_by_relevance(arr)
    arr.sort_by { |a| -a.relevance }
  end
end
