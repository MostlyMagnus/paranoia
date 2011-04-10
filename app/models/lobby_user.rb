class LobbyUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :lobby
  
end
