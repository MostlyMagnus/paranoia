
# == Schema Information
# Schema version: 20110427204910
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
#  game_speed         :integer
#

class Lobby < ActiveRecord::Base
  has_many :lobby_users, :dependent => :destroy # lobbyusers are still not destroyed when deleting lobby
  has_many :users, :through => :lobby_users
  
  # add this later
  #belongs_to :user, :foreign_key => "created_by_user_id" 
   
  # should probably validate more things, but keep it like this for now.
  validates :name,  :presence => true, 
                    :length => { :minimum => 5 }
  
  
  attr_accessor :has_current_user
  
  def join
    logger.debug "Lobby:join"
  end
  
  def self.find_available_lobbies(current_user)
    lobbies = self.all
    lobbies.each do |lobby|
      lobby.has_current_user = lobby.lobby_users.exists?(:user_id => current_user.id)
    end
  end
  
  def self.find_non_user_lobbies
    
  end
  
  def self.create_new
    #l = Lobby.new(:id => 1, :name => 'Lobby x', :description => 'desc', :max_slots => 12)
    self.create(:name => 'Lobby x', :description => 'desc', :max_slots => 12, :game_speed => 5)
    
  end
  
  def self.leave(lobby_id, current_user_id)
    lobby = self.find(lobby_id) # should probably make sure the lobby is still there.
    if lobby.lobby_users.exists?(:user_id => current_user_id)
      lu = lobby.lobby_users.where(:user_id => current_user_id).first
      lu.destroy
    end
  end
  
  # Will try to join the current user unless the user is already in the game.
  def self.join(lobby_id, current_user_id)
    lobby = self.find(lobby_id)
    # Needs an extra check to really make sure the lobby is not full a this time
    if not lobby.lobby_users.exists?(:user_id => current_user_id)
      LobbyUser.create(:user_id => current_user_id, :lobby_id => lobby.id)
    end
  end

  
end
