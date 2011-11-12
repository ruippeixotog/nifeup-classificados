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
  has_many :comments
  
  has_attached_file :thumbnail, :styles => { :medium => "200x200" }

  @@OPTIONS = {:opened => 0, :closed => 1, :locked => 2}
  
  @@RELEVANCE_TIME_OFFSET = 2.weeks.to_i
  @@RELEVANCE_USER_SCALE = 1000

  class CannotOpenAdError < RuntimeError; end
  class AdNotClosedError < RuntimeError; end
  class EvalUserNotDefinedError < RuntimeError; end
  class UserAlreadyDefinedError < RuntimeError; end
  class UnauthorizedUserException < RuntimeError; end
  class EvalAlreadyDoneError < RuntimeError; end
  
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
    self.closed == @@OPTIONS[:opened]
  end
  
  def locked?
    self.closed == @@OPTIONS[:locked]
  end
  
  def close!
    self.closed = @@OPTIONS[:closed]
    self.save
  end
  
  def open!
    raise CannotOpenAdError unless not self.locked?    
    self.closed = @@OPTIONS[:opened]
    self.save
  end
  
  def close_permanently!
    self.closed = @@OPTIONS[:locked]
    self.save
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
  
  def rate!(user_id, value)
    raise ArgumentError unless (value != nil && value > 0 && value < 6)
  
    evaluation = Evaluation.find_or_create_by_user_id_and_ad_id :user_id => user_id, :ad_id => self.id
    if evaluation.value != nil
      @size = self.evaluations.size
      @cur_value = @size * self.average_rate - evaluation.value + value
      self.average_rate = @cur_value / @size
    else
      self.average_rate = self.calc_average_rating(user_id,value)
    end 
    self.save
    evaluation.value = value
    evaluation.save
      
  end
  
  def calc_average_rating(user_id,value)
     @total = self.evaluations.size
     if not self.average_rate
       value
     else
       @old_average = self.average_rate * (@total - 1)
       (value + @old_average)/@total
     end
  end
  
  def user_rating(user_id)
    evaluation = Evaluation.find_by_user_id_and_ad_id(user_id, self.id)
    evaluation.value unless not evaluation
  end
  
  def final_eval_user_id
    self.final_evaluation.user_id unless not self.final_evaluation
  end
  
  def final_eval
    self.final_evaluation.value unless not self.final_evaluation
  end
  
  def set_final_eval_user!(user_id)
    raise AdNotClosedError if self.open?
    raise UserAlreadyDefinedError unless not self.final_evaluation
  
    final_eval = FinalEvaluation.new :user_id => user_id
    final_eval.save
    self.final_evaluation = final_eval
    self.save
  end
  
  def do_final_eval!(user_id, value)
    raise EvalUserNotDefinedError unless (self.final_evaluation && self.final_evaluation.user_id)
    raise EvalAlreadyDoneError unless not self.final_evaluation.complete?
    raise UnauthorizedUserException unless self.final_evaluation.user_id == user_id
    
    self.final_evaluation.value = value
    self.final_evaluation.save
  end
  
  def relevance
    self.created_at.to_i + relevance_factor * @@RELEVANCE_TIME_OFFSET / 2.0
  end
  
  def relevance_factor
    ad_rate_count = self.evaluations.count
    user_rate_count = FinalEvaluation.where(:user_id => self.user_id).count
    total_rates = ad_rate_count + user_rate_count
    return 0.0 if total_rates == 0
    
    ad_rate = self.average_rate
    ad_rate ||= 0
    user_rate = self.user.rate
    user_rate ||= 0
    
    ad_rate_factor = [ad_rate_count / 1000.0, 1.0].min * (ad_rate - 3.0) / 2.0
    user_rate_factor = [user_rate_count / 1000.0, 1.0].min * (user_rate - 3.0) / 2.0
    return (ad_rate_factor * ad_rate_count + user_rate_factor * user_rate_count) / total_rates
  end
  
  def calc_average_rating!(user_id, value)
    @total = self.evaluations.size
    if self.average_rate == nil
      self.average_rate = value
      self.save
    else
      @old_average = self.average_rate * (@total - 1)
      self.average_rate = (value + @old_average) / @total
      self.save     
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
