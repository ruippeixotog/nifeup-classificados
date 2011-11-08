class Resource < ActiveRecord::Base
  belongs_to :ad
  has_attached_file :link, :styles => { :gallery => "60x60>" }
end
