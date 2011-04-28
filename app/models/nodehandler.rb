require 'StructDef'

class NodeTypeDef
  N_NIL               = nil

  N_AIRLOCK_ACTIVATOR = "a"
  N_CONTROL_PANEL     = "c"
  N_ENGINE            = "e"
  N_GENERATOR         = "g"  
  N_WATER_CONTAINER   = "w"
end

class NodeHandler
  attr_accessor :logicNodes

  def initialize(gamestate)
    buildLogicNodes(gamestate)
  end
  
  def buildLogicNodes(gamestate)
    # If there is no node status built, then we need to build it. This should never happen later
    # but for now I wrote the code so we have a syntax for parsing and working with nodes.        
    if gamestate.nodestatus.nil? then gamestate.nodestatus = buildNodestatus(gamestate) end
    
    @logicNodes = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
    
    #id; type; x, y; health$
    splitNodestatus = gamestate.nodestatus.split("$")
    
    splitNodestatus.each do |nodeStatus|
      nodeSplit = nodeStatus.split(";")
            
      pos = S_Position.new(Integer(nodeSplit[2].split(",")[0]), Integer(nodeSplit[2].split(",")[1]))
          
      pushNode = nil
      
      case nodeSplit[1]
        when NodeTypeDef::N_AIRLOCK_ACTIVATOR then pushNode = N_Airlock_Activator.new(pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_CONTROL_PANEL     then pushNode = N_Control_Panel.new(pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_ENGINE            then pushNode = N_Engine.new(pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_GENERATOR         then pushNode = N_Generator.new(pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_WATER_CONTAINER   then pushNode = N_Water_Container.new(pos, nodeSplit[1], nodeSplit[3])
        else                                       pushNode = N_Nil.new(pos, nodeSplit[1], nodeSplit[3])
      end
        
      @logicNodes[pos.x][pos.y] = pushNode
    end
    
  end
  
  def buildNodestatus(gamestate)
    gamestate.shipSetup
    
    id = 0
    nodestatusString = ""
    
    gamestate.ship.nodes.each do |node|
      #id; type; x, y; health$
      nodestatusString += String(id)+";"+node.node_type+";"+String(node.position[:x])+","+String(node.position[:y])+";1$"
      id+=1
    end
    
    return nodestatusString
  end
end

class LogicNode
  def initialize(pos, node_type, health)
    @position   = pos
    @node_type  = node_type
    @health = health
  end
  
  attr_accessor :position, :node_type, :health
end

class N_Airlock_Activator < LogicNode 
end

class N_Control_Panel < LogicNode 
end

class N_Engine < LogicNode 
end

class N_Generator < LogicNode 
end

class N_Water_Container < LogicNode 
end

class N_Nil < LogicNode 
end
