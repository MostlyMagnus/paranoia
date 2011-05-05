require 'StructDef'

class NodeTypeDef
  N_NIL               = nil

  N_AIRLOCK_ACTIVATOR = "a"
  N_CONTROL_PANEL     = "c"
  N_ENGINE            = "e"
  N_GENERATOR         = "g"  
  N_WATER_CONTAINER   = "w"
end

class GameShip
  attr_accessor :logic_nodes, :rooms

  def initialize(gamestate)
    @gamestate = gamestate
    
    setup_ship
    build_logic_nodes
  end
  
  def setup_ship
    # Always call this function in code that needs to use this gamestates ship
    if @ship.nil? then 
      @ship = Ship.find_by_id(@gamestate.ship_id)
      
      parse_game_ship_from_ship
      parse_nodes_from_ship
    end
  end
  
  def build_logic_nodes
    # If there is no node status built, then we need to build it. This should never happen later
    # but for now I wrote the code so we have a syntax for parsing and working with nodes.        
    if @gamestate.nodestatus.nil? then @gamestate.nodestatus = create_node_status_from_ship end
    
    @logic_nodes = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
    
    #id; type; x, y; health$
    splitNodestatus = @gamestate.nodestatus.split("$")
    
    splitNodestatus.each do |nodeStatus|
      nodeSplit = nodeStatus.split(";")
            
      pos = S_Position.new(Integer(nodeSplit[2].split(",")[0]), Integer(nodeSplit[2].split(",")[1]))
          
      pushNode = nil
      
      case nodeSplit[1]
        when NodeTypeDef::N_AIRLOCK_ACTIVATOR then pushNode = N_Airlock_Activator.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_CONTROL_PANEL     then pushNode = N_Control_Panel.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_ENGINE            then pushNode = N_Engine.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_GENERATOR         then pushNode = N_Generator.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3])
        when NodeTypeDef::N_WATER_CONTAINER   then pushNode = N_Water_Container.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3])
        else                                       pushNode = N_Nil.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3])
      end
        
      @logic_nodes[pos.x][pos.y] = pushNode
    end
  end
  
  def create_node_status_from_ship
    setup_ship
    
    id = 0
    nodestatusString = ""
    
    @nodes.each do |node|
      #id; type; x, y; health$
      nodestatusString += String(id)+";"+node.node_type+";"+String(node.position[:x])+","+String(node.position[:y])+";1$"
      id+=1
    end
    
    return nodestatusString
  end
  
  def get_node_by_id(id)
    @nodes.each do |h, k|
      k.each do |_h,_k|
        if _k.id == id
          # Does this work?
          return _k
        end
      end
    end
  end
  
  def parse_game_ship_from_ship
    setup_ship
    
    @rooms  = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
        
    # 0,0;x00x;g1;n1$1,0;x0x0;c1;$2,0;x0x0;c1;$3,0;xx00;c1$0,1;0x0x;c1;$
    # 3,1;0x0x;c1;$0,2;0xrx;e;n0,n2$3,2;1xrx;b;n3$0,3;r0xx;e;n0,n2$
    # 1,3;x0x0;c1;$2,3;x0x0;c1;$3,3;rxx0;b;n3$
    splitShip = @ship.layout.split("$")
    
    splitShip.each do |room|
      splitRoom = room.split(";")
      
      # First we get the position
      pos = S_Position.new(Integer(splitRoom[0].split(",")[0]), Integer(splitRoom[0].split(",")[1]))
      
      # Then we get the access codes
      access = S_Access.new(String(splitRoom[1][0]), String(splitRoom[1][1]), String(splitRoom[1][2]), String(splitRoom[1][3]))
                  
      # Lets put it in our hash (-That's what SHE said!)        
      @rooms[pos.x][pos.y] = Room.new(pos, access, splitRoom[2])      
    end    
  end
  
  def parse_nodes_from_ship
    @nodes  = Array.new
    
    splitShip = @ship.layout.split("$")
    
    splitShip.each do |room|
      splitRoom = room.split(";")
      
      pos = S_Position.new(Integer(splitRoom[0].split(",")[0]), Integer(splitRoom[0].split(",")[1]))
       
      # Parse the nodes into an array.    
      if !splitRoom[3].nil? then
        @nodes.push(Ship_Node.new(pos, splitRoom[3]))    
      end
    end        
  end
  
  def where_can_i_move_from_here?(pawn)
    # Future code here should take into account access levels
    # @rooms[pawn.x][pawn.y].access[:north]

    #allowedMoves = S_Access.new(0, 0, 0, 0)
    allowedMoves = Hash[:north => 0, :south => 0, :east => 0, :west => 0]   
    if @rooms[pawn.x][pawn.y-1].kind_of? Room then
      #There's a room north
      unless @rooms[pawn.x][pawn.y].access[:north] == "x"
        allowedMoves[:north] = 1   
      end
    end
 
    if @rooms[pawn.x][pawn.y+1].kind_of? Room then
      #There's a room south
      unless @rooms[pawn.x][pawn.y].access[:south] == "x"
        allowedMoves[:south] = 1   
      end
    end
      
    if @rooms[pawn.x-1][pawn.y].kind_of? Room then
      #There's a room west
      unless @rooms[pawn.x][pawn.y].access[:west] == "x"
        allowedMoves[:west] = 1   
      end
    end
 
    if @rooms[pawn.x+1][pawn.y].kind_of? Room then
      #There's a room east
      unless @rooms[pawn.x][pawn.y].access[:east] == "x"
        allowedMoves[:east] = 1   
      end
    end
    
    # Return
    return allowedMoves
  end
  
  def AJAX_formatForResponse
    setup_ship
    
    toAjaxResponse = Hash.new
    
    toAjaxResponse[:name] = @ship.name
    toAjaxResponse[:width] = 16
    toAjaxResponse[:height] = 8
    
    toAjaxResponse[:map] = @rooms
    toAjaxResponse[:nodes]  = @logic_nodes
    
    return toAjaxResponse
  end  
end

class Room
  def initialize(pos, access, room_type)
    @position   = pos
    @access     = access
    @room_type  = room_type
  end

  attr_accessor :position, :access, :room_type
end

class Ship_Node
  def initialize(pos, node_type)
    @position   = pos
    @node_type  = node_type
  end
  
  attr_accessor :position, :node_type
end

class LogicNode
  attr_accessor :id, :position, :node_type, :health

  def initialize(id, pos, node_type, health)
    @id = id
    @position   = pos
    @node_type  = node_type
    @health = health
  end  

  def repair(amount)
  end
  
  def sabotage(amount)
  end
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
