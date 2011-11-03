class Ad < ActiveRecord::Base
  belongs_to :user
  belongs_to :section
  has_many :resources
  has_many :favorites
  has_many :users, :through => :favorites

  has_attached_file :thumbnail, :styles => { :thumb => "140x180>", :medium => "250x250>" }
  
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
end
