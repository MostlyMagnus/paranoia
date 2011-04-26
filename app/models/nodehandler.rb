require 'StructDef'

class NodeHandler
  attr_accessor :logicNodes
  
  def buildLogicNodes(gamestate)
    
    @logicNodes = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
    
    #id; type; x, y; health$
    splitNodestatus = gamestate.nodestatus.split("$")
    
    splitNodestatus.each do |nodeStatus|
      nodeSplit = nodeStatus.split(";")
            
      pos = S_Position.new(Integer(nodeSplit[2].split(",")[0], Integer(nodeSplit[2].split(",")[1])))
      
      @logicNodes[pos.x][pos.y] = LogicNode.new(pos, nodeSplit[1], nodeSplit[3])
    end
    
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
