class Resource < ActiveRecord::Base
  belongs_to :ad
  has_attached_file :link, :styles => { :gallery => "60x60", :medium => "200x200" }
  
  validates_attachment_presence :link
  validates_attachment_size :link, :less_than => 5.megabytes
  validates_attachment_content_type :link, :content_type => ['image/jpeg', 'image/png', 'application/pdf']
end
