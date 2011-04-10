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

class ActionTypeDef
  A_NIL     = nil
  A_USE     = 1
  A_KILL    = 2
  A_REPAIR  = 3
end

class Action < ActiveRecord::Base
  belongs_to :pawn
  
  default_scope :order => 'queue_number ASC'
  
  attr_accessor :priority
  
  # Lets pass a hash of paramters instead, so that all the constructors have
  # the same number of parameters
  
  # If nothing is passed we default to an empty hash to please Ruby
  def initialize(params = Hash.new)
    # super to make sure that the ActiveRecord constructor gets called
    super
    
    # if we actually passed a params[:priority] then we set @priority to that
    if !params[:priority].nil? then @priority = params[:priority] end
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
    end
  end
end

# A nil action in case something goes wrong and we don't have a action_type set
class A_Nil < Action
  def initialize(params = Hash.new)
    #
    # NOTE - Execute in this order
    #     default_priority(x) - sets the default priority of the action
    #
    #     super calls the parent constructor. If we've passed a :priority
    #           in the params hash this will overwrite the previous priority
    #
    # Always let super end the constructor
    #
    @action_type = ActionTypeDef::A_NIL
    
    default_priority(-500)    
    
    super        
  end 
end

class A_Use < Action
  
  def initialize(params = Hash.new)
    @action_type = ActionTypeDef::A_USE
    
    if !params[:node].nil? then @node = params[:node] end
    default_priority(50)
    super
  end
  
end

class A_Kill < Action
  
  def initialize(params = Hash.new)
    @action_type = ActionTypeDef::A_KILL
    
    if !params[:pawn].nil? then @pawn = params[:pawn] end    
    default_priority(-100)    
    super
  end
  
end

class A_Repair < Action
  
  def initialize(params = Hash.new)
    @action_type = ActionTypeDef::A_REPAIR
    
    if !params[:node].nil? then @node = params[:node] end
    default_priority(80)
    super
  end
  
end
