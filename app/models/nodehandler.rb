require 'StructDef'

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
      
      # We should push the right type of subclass into the hash here, but for now
      # we only have the default logic node.
      
      # Problem: what if there is several nodes in the same slot? Then this
      # will overwrite. Think think.
      @logicNodes[pos.x][pos.y] = LogicNode.new(pos, nodeSplit[1], nodeSplit[3])
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

class Node_Nil < LogicNode 
  attr_accessor :interactive
end
