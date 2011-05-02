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
  has_many :lobby_users
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
  
  def self.find_user_lobbies
    #self.joins(:lobby_users).where(:lobby_users => {:lobby_id = id})
    s = 'select lobbies.id, lobbies.name, lobbies.description, lobbies.max_slots, lobby_users.user_id'
    s << ' from lobbies'
    s << ' inner join lobby_users on lobby_users.lobby_id = lobbies.id'
    s << ' where lobby_users.user_id = 2'
    
    q = self.find_by_sql(s)
    q.each do |row|
        RAILS_DEFAULT_LOGGER.debug row.inspect()
    end
    q
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
    self.create(:name => 'Lobby x', :description => 'desc', :max_slots => 12)
    
  end
  
  def self.leave(lobby_id, current_user_id)
    lobby = Lobby.find(lobby_id)
    if lobby.lobby_users.exists?(:user_id => current_user_id)
      logger.debug ">>>> current user is here!!!"
      # need to destroy record here.
    end

  end
end
