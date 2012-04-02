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

require 'appconfig'

class Pawn < ActiveRecord::Base
  # We might need to change this, but I imagine you should never access this through the web. It will be handled by code.
  # attr_accessible #none
  
  belongs_to :user
  has_many :actions,:dependent => :destroy
  has_many :notifications,:dependent => :destroy
  
  validates :user_id,       :presence => true
  validates :gamestate_id,  :presence => true
  validates :role,          :presence => true
  
  def addAction(queue_number, action_type, details)
    #@user_pawn.actions.create(:queue_number => @queue_number, :action_type => params[:type], :params => params[:details]) end
        
    totalCost = 0
    
    self.actions.each do |action|
      totalCost += action.actionToSpecificActionType.tick_cost
    end
 
    tempAction = Action.new(:queue_number => queue_number, :action_type => action_type, :params => details)
 
    if totalCost + tempAction.actionToSpecificActionType.tick_cost <= AppConfig::ACTION_TOTAL_AP then
      self.actions.create(:queue_number => queue_number, :action_type => action_type, :params => details)
    else
      return false
    end
    
    return true
    
  end
end
