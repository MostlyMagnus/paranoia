# == Schema Information
# Schema version: 20110408204913
#
# Table name: actions
#
#  id           :integer         not null, primary key
#  pawn_id      :integer
#  queue_number :integer
#  action_type  :integer
#  params       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

require 'ActionTypeDef'

class Action < ActiveRecord::Base
  belongs_to :pawn
  
  default_scope :order => 'queue_number ASC'
  
  attr_accessor :priority, :tick_cost
  
  # Lets pass a hash of paramters instead, so that all the constructors have
  # the same number of parameters
  
  # If nothing is passed we default to an empty hash to please Ruby
  def initialize(parameters = Hash.new)
    # super to make sure that the ActiveRecord constructor gets called
    super
    
    # if we actually passed a parameters[:priority] then we set @priority to that
    if !parameters[:priority].nil? then @priority = parameters[:priority] end
  end
  
  def default_priority(priority = nil)
    if !priority.nil? then @priority = priority else @priority = -1000 end
  end
    
  def typeToString 
    case self.action_type
      when ActionTypeDef::A_NIL
        "A_Nil"
      when ActionTypeDef::A_USE
        "A_Use"
      when ActionTypeDef::A_KILL
        "A_Kill"
      when ActionTypeDef::A_REPAIR
        "A_Repair"
      when ActionTypeDef::A_MOVE
        "A_Move"
      when ActionTypeDef::A_VOTE
        "A_Vote"
      when ActionTypeDef::A_INITVOTE
        "A_InitVote"
      when ActionTypeDef::A_STATUS
        "A_Status"        
    end
  end
end

# A nil action in case something goes wrong and we don't have a action_type set
class A_Nil < Action
  def initialize(parameters = Hash.new)
    #
    # NOTE - Execute in this order
    #     default_priority(x) - sets the default priority of the action
    #
    #     super calls the parent constructor. If we've passed a :priority
    #           in the parameters hash this will overwrite the previous priority
    #
    # Always let super end the constructor
    #
    @action_type = ActionTypeDef::A_NIL
    @tick_cost = 0
    
    default_priority(-500)    
    
    super        
  end 
end

class A_Use < Action
  attr_accessor :target_node
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_USE
    @target_node = parameters["params"].split(",").first.to_i
    @tick_cost = 2
    
    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(50)
    super
  end
  
end

class A_Kill < Action
  attr_accessor :target_pawn_id
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_KILL
    @tick_cost = 4

    @target_pawn_id = parameters["params"].split(",")[0]
    
    if !parameters[:pawn].nil? then @pawn = parameters[:pawn] end    
    default_priority(-100)    
    super
  end
  
end

class A_Repair < Action
  attr_accessor :target_node, :multiplier
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_REPAIR
    @tick_cost = 2
    
    @target_node = parameters["params"].split(",").first.to_i
    @multiplier  = parameters["params"].split(",").last.to_i
    
    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(80)
    super
  end
  
end

class A_Move < Action
  attr_accessor :toX, :toY
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_MOVE
    @tick_cost = 1
    
    @toX = parameters["params"].split(",")[0]
    @toY = parameters["params"].split(",")[1]
        
    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(80)
    super
  end
  
end

class A_InitVote < Action
  attr_accessor :target
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_INITVOTE
    @tick_cost = 2
    
    @target = parameters["params"]
    
    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(80)
    super
  end
  
end

class A_Vote < Action
  attr_accessor :event_id, :input
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_VOTE
    @tick_cost = 5
    
    @event_id    = parameters["params"].split(",")[0]
    @input       = parameters["params"].split(",")[1]
    
    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(80)
    super
  end
  
end

class A_Status < Action
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_STATUS
    @tick_cost = 2

    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(80)
    super
  end
  
end
