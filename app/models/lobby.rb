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
  
  
  def join
    logger.debug "Lobby:join"
  end
  
  def self.find_user_lobbies
    #self.joins(:lobby_users).where(:lobby_users => {:lobby_id = id})
    s = 'select lobbies.*, lobby_users.user_id from lobbies'
    s << ' inner join lobby_users on lobby_users.lobby_id = lobbies.id'
    s << ' where lobby_users.user_id = 2'
    self.find_by_sql(s)
  end
  
  def self.find_non_user_lobbies
    
  end
  
end
