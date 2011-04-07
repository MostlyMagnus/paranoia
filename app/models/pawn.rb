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

  def repair(params)
    target_id = params[:target_id]
  end
  
  def sabotage(params)
    target_id = params[:target_id]
  end
  
  def use(params)
    target_id = params[:target_id]
  end
  

  def investigate(params)
    target_id = params[:target_id]
  end

  def interrogate(params)
    target_id = params[:target_id]
  end

  def kill(params)
    target_id = params[:target_id]
  end


  def be_investigated(params)
    targeter_id = params[:targeter_id]
  end

  def be_interrogated(params)
    targeter_id = params[:targeter_id]
  end

  def be_killed(params)
    targeter_id = params[:targeter_id]
  end


  def move(params)
  end
  
end
