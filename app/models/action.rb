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

require 'actiontypedef'

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
  
  def actionToSpecificActionType
    #This will parse the params of the action as well
    case self.action_type
      when ActionTypeDef::A_NIL        
        returnAction = A_Nil.new(self.attributes)
        
      when ActionTypeDef::A_USE
        returnAction = A_Use.new(self.attributes)
        
      when ActionTypeDef::A_REPAIR
        returnAction = A_Repair.new(self.attributes)
        
      when ActionTypeDef::A_KILL
        returnAction = A_Kill.new(self.attributes)        

      when ActionTypeDef::A_MOVE
        returnAction = A_Move.new(self.attributes)

      when ActionTypeDef::A_INITVOTE
        returnAction = A_InitVote.new(self.attributes)

      when ActionTypeDef::A_VOTE
        returnAction = A_Vote.new(self.attributes)

      when ActionTypeDef::A_STATUS
        returnAction = A_Status.new(self.attributes)

    end
    
    returnAction
  end
 
  def getTickCost
    # Returns the tick cost of this specific action
    case self.action_type
      when ActionTypeDef::A_NIL        
        0
        
      when ActionTypeDef::A_USE
        AppConfig::ACTION_COST_USE
                
      when ActionTypeDef::A_REPAIR
        AppConfig::ACTION_COST_REPAIR
        
      when ActionTypeDef::A_KILL
        AppConfig::ACTION_COST_KILL        

      when ActionTypeDef::A_MOVE
        AppConfig::ACTION_COST_MOVE

      when ActionTypeDef::A_INITVOTE
        AppConfig::ACTION_COST_INITVOTE

      when ActionTypeDef::A_VOTE
        AppConfig::ACTION_COST_VOTE

      when ActionTypeDef::A_STATUS
        AppConfig::ACTION_COST_STATUS

    end
    
    nil
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
    @tick_cost = AppConfig::ACTION_COST_USE
    
    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(50)
    super
  end
  
end

class A_Kill < Action
  attr_accessor :target_pawn_id
  
  def initialize(parameters = Hash.new)
    @action_type = ActionTypeDef::A_KILL
    @tick_cost =  AppConfig::ACTION_COST_KILL

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
    @tick_cost =  AppConfig::ACTION_COST_REPAIR
    
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
    @tick_cost =  AppConfig::ACTION_COST_MOVE
    
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
    @tick_cost =  AppConfig::ACTION_COST_INITVOTE
    
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
    @tick_cost =  AppConfig::ACTION_COST_VOTE
    
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
    @tick_cost =  AppConfig::ACTION_COST_STATUS

    if !parameters[:node].nil? then @node = parameters[:node] end
    default_priority(80)
    super
  end
  
end
