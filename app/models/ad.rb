class Ad < ActiveRecord::Base
  belongs_to :user
  belongs_to :section
  belongs_to :final_evaluation
  has_many :favorites
  has_many :ad_tags
  has_many :users, :through => :favorites
  has_many :evaluations
  has_many :raters, :through => :evaluations, :source => :users
  has_many :comments, :dependent => :destroy
  has_many :resources, :dependent => :destroy
  # TODO reject empty
  accepts_nested_attributes_for :resources, :reject_if => lambda { |r| not r[:link] }, :allow_destroy => true

  validates_presence_of :title
  
  # tags saving process
  attr_writer :tag_names
  after_save :assign_tags
  
  # thumbnail choose and cropping process 
  has_attached_file :thumbnail, :styles => { :thumb => "140x180", :medium => "200x200" }, :processors => [:cropper]
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_avatar, :if => :cropping?
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def thumb_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(thumbnail.path(style))
  end
  
  scope :all_opened, where(:closed => false)
  scope :distinct, select("DISTINCT ads.id, ads.*")

  @@OPTIONS = {:opened => 0, :closed => 1, :locked => 2}
  
  @@RELEVANCE_TIME_OFFSET = 1.weeks.to_i
  @@RELEVANCE_USER_SCALE = 1000

  cattr_accessor :RELEVANCE_TIME_OFFSET
  cattr_accessor :RELEVANCE_USER_SCALE

  class CannotOpenAdError < RuntimeError; end
  class AdNotClosedError < RuntimeError; end
  class EvalUserNotDefinedError < RuntimeError; end
  class UserAlreadyDefinedError < RuntimeError; end
  class UnauthorizedUserException < RuntimeError; end
  class EvalAlreadyDoneError < RuntimeError; end

  self.per_page = 10 
  
  def self.most_relevant(count)
    return nil if count.nil? || count < 0
    return [] if count == 0
    order_by_relevance(all_opened).first(count)
  end
  
  def self.search_text(text, page)
    query = order_by_relevance(all_opened.distinct)
    return query.paginate(:page => page) if text.nil? || text.empty?
    
    query = query.search(:title_or_ad_tags_tag_contains_any => text.split)
    return query.paginate(:page => page)
  end
  
  def self.search_text_by_section(section_id, text, page)
    query = order_by_relevance(Section.find(section_id).ads.all_opened.distinct)
    return query.paginate(:page => page) if text.nil? || text.empty?
    
    query = query.search(:title_or_ad_tags_tag_contains_any => text.split)
    return query.paginate(:page => page)
  end

  def self.order_by_relevance(rel)
    rel.order("strftime(\"%s\", ads.created_at) + ads.relevance_factor * #{ @@RELEVANCE_TIME_OFFSET } DESC");
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
    evaluation.value = value
    evaluation.save

    self.relevance_factor = self.calc_relevance
    self.save
  end
  
  def calc_average_rating(user_id,value)
     @total = self.evaluations.size
     if not self.average_rate
       value
     else
       @old_average = self.average_rate * (@total - 1)
       (value + @old_average) / @total
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

    self.relevance_factor = self.calc_relevance
    self.save
  end
  
  def relevance
    self.created_at.to_i + self.relevance_factor * @@RELEVANCE_TIME_OFFSET
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
    self.resources.where('resources.link_content_type LIKE ?', 'image/%')
  end

  # calculates and returns a relevance factor in the range [-1.0, 1.0]
  def calc_relevance
    ad_rate_count = self.evaluations.count
    user_rate_count = FinalEvaluation.where(:user_id => self.user_id).count
    total_rates = ad_rate_count + user_rate_count
    return 0.0 if total_rates == 0

    ad_rate = self.average_rate
    ad_rate ||= 0
    user_rate = self.user.rate
    user_rate ||= 0

    ad_rate_factor = [ad_rate_count / @@RELEVANCE_USER_SCALE.to_f, 1.0].min * (ad_rate - 3.0) / 2.0
    user_rate_factor = [user_rate_count / @@RELEVANCE_USER_SCALE.to_f, 1.0].min * (user_rate - 3.0) / 2.0
    return (ad_rate_factor * ad_rate_count + user_rate_factor * user_rate_count) / total_rates
  end

  # tagging system
  def tag_names
    @tag_names || ad_tags.map(&:tag).join(' ')
  end
  
  #business partner
  def partner
    User.find(final_eval_user_id)
  end
  
  def partner=(user_name)
    user = User.find_by_username(user_name)
    if user
      set_final_eval_user! user.id
    end
  end
  
  private

  def assign_tags
    if @tag_names
      self.ad_tags = @tag_names.split(/\s+/).map do |name|
        AdTag.find_or_create_by_ad_id_and_tag(self.id, name)
      end
    end
  end

  # cropping the avatar
  def reprocess_avatar
    thumbnail.reprocess!
  end
end
