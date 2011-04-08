# == Schema Information
# Schema version: 20110402133936
#
# Table name: pawns
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  gamestate_id :integer
#  persona_id   :integer
#  role         :integer
#  action_queue :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Pawn < ActiveRecord::Base
  # We might need to change this, but I imagine you should never access this through the web. It will be handled by code.
  # attr_accessible #none
  
  belongs_to :user
  
  validates :user_id,       :presence => true
  validates :gamestate_id,  :presence => true
  validates :role,          :presence => true

end
