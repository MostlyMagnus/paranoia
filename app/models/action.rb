# == Schema Information
# Schema version: 20110408110929
#
# Table name: actions
#
#  id           :integer         not null, primary key
#  pawn_id      :integer
#  queue_number :integer
#  type         :integer
#  params       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Action < ActiveRecord::Base
  belongs_to :pawn
  
  default_scope :order => 'queue_number ASC'
  
  attr_accessor :priority
  
  def initialize
    @priority = 0
  end

end

class A_Nil < Action
  
  def initialize(priority=100)
    @priority = priority
  end
  
end

class A_Use < Action
  
  def initialize(node, priority=50)
    @priority = priority
  end
  
end

class A_Kill < Action
  
  def initialize(pawn, priority=-100)
    @pawn = pawn
    @priority = priority
  end
  
end

class A_Repair < Action
  
  def initialize(node, priority=80)
    @node = node
    @priority = priority
  end
  
end