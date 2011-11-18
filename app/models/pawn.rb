# == Schema Information
# Schema version: 20110408204913
#
# Table name: pawns
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  gamestate_id :integer
#  persona_id   :integer
#  role         :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Pawn < ActiveRecord::Base
  # We might need to change this, but I imagine you should never access this through the web. It will be handled by code.
  # attr_accessible #none
  
  belongs_to :user
  has_many :actions,:dependent => :destroy
  has_many :notifications,:dependent => :destroy
  
  validates :user_id,       :presence => true
  validates :gamestate_id,  :presence => true
  validates :role,          :presence => true

  def actionQueue
    Action.find_all_by_pawn_id(self.id)
  end
end
