class Lobby < ActiveRecord::Base
  has_many :lobby_users
  has_many :users, :through => :lobby_users
  
  # add this later
  #belongs_to :user, :foreign_key => "created_by_user_id" 
   
  # should probably validate more things, but keep it like this for now.
  validates :name,  :presence => true, 
                    :length => { :minimum => 5 }
  
  
end
