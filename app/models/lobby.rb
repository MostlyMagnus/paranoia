# == Schema Information
# Schema version: 20110410174552
#
# Table name: lobbies
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  description        :string(255)
#  min_slots          :integer
#  max_slots          :integer
#  has_password       :integer
#  password           :string(255)
#  ship_id            :integer
#  created_by_user_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Lobby < ActiveRecord::Base
  has_many :lobby_users
  has_many :users, :through => :lobby_users
  
  # add this later
  #belongs_to :user, :foreign_key => "created_by_user_id" 
   
  # should probably validate more things, but keep it like this for now.
  validates :name,  :presence => true, 
                    :length => { :minimum => 5 }
  
  
end
