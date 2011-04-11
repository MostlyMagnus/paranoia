# == Schema Information
# Schema version: 20110410174552
#
# Table name: lobby_users
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  lobby_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class LobbyUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :lobby
  
end
