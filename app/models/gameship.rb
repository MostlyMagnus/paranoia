require 'structdef'
require 'appconfig'

class NodeTypeDef
  N_NIL               = nil

  N_AIRLOCK_ACTIVATOR = "n_air1"
  N_CONTROL_PANEL     = "n_con1"
  N_ENGINE            = "n_eng1"
  N_GENERATOR         = "n_gen1"  
  N_WATER_CONTAINER   = "n_wat1"
end

class GameShip
  attr_accessor :logic_nodes, :rooms

  def initialize(ship_id, nodestatus)	
    @ship_id = ship_id
	
    setup_ship(@ship_id)
    build_logic_nodes(nodestatus)
  end
  
  def getTempShip
    return "11,0;xx0x;g1;n_gen1$16,0;xx0x;g1;n_gen1$11,1;0x0x;c1$16,1;0x0x;c1$11,2;0x0x;c1$16,2;0x0x;c1$8,3;x00x;c1$9,3;x0x0;c1$10,3;x0x0;c1$11,3;0000;r1$12,3;x0x0;c1$13,3;x0x0;c1$14,3;x0x0;c1$15,3;x0x0;c1$16,3;0xr0;cr1$8,4;0x0x;c1$11,4;0x0x;c1$16,4;rx0x;cr1$4,5;xx0x;g1$6,5;xx0x;g1$8,5;0x0x;c1$11,5;0x0x;c1$16,5;0x0x;c1$4,6;0x0x;c1$6,6;0x0x;c1$10,6;xrrx;b1$11,6;0xrr;b1$16,6;0x0x;c1$2,7;x00x;c1$3,7;x0x0;c1$4,7;00x0;c1$5,7;x0x0;c1$6,7;00x0;c1$7,7;x0x0;c1$8,7;00x0;c1$9,7;x0x0;c1$10,7;rrr0;b1$11,7;r0rr;b1$12,7;x0x0;c1$13,7;x0x0;c1$14,7;x0x0;c1$15,7;x0x0;c1$16,7;0x00;r2$2,8;0x0x;c1$10,8;rrxx;b1$11,8;rx0r;b1$16,8;0x0x;c1$2,9;0x0x;c1$11,9;0x0x;c1$16,9;0x0x;c1$0,10;x0xx;e1;n_eng1$1,10;x0x0;c1$2,10;0x00;c1$11,10;0x0x;c1$16,10;0x0x;r_air;n_air1$2,11;0x0x;c1$11,11;0x0x;c1$16,11;0x0x;c1$2,12;000x;c1$3,12;x0x0;c1$4,12;x0x0;c1$5,12;x0x0;c1$6,12;x0x0;c1$7,12;x0x0;c1$8,12;x000;c1$9,12;x0x0;c1$10,12;x0x0;c1$11,12;00x0;r3$12,12;x0x0;c1$13,12;x000;c1$14,12;x0x0;c1$15,12;x0x0;c1$16,12;0x00;c1$2,13;0x0x;c1$8,13;0x0x;c1$13,13;0x0x;c1$16,13;0x0x;c1$2,14;0x0x;c1$8,14;0x0x;c1$13,14;0x0x;c1$16,14;0x0x;c1$2,15;00xx;c1$3,15;x0x0;c1$4,15;x0x0;w1;n_wat1$5,15;x0x0;c1$6,15;x0x0;w1;n_wat1$7,15;x0x0;c1$8,15;0xx0;w1;n_wat1$13,15;00xx;w1;n_wat1$14,15;x0x0;c1$15,15;x0x0;w1;n_wat1$16,15;0xx0;c1"
  end
  
  def setup_ship(ship_id)
    # Always call this function in code that needs to use this gamestates ship    
    if @ship.nil? then
      
	  @ship = Ship.find_by_id(ship_id)    
    
      parse_game_ship_from_ship
      parse_nodes_from_ship
    end
  end
  
  def build_logic_nodes(nodestatus)
    # If there is no node status built, then we need to build it. This should never happen later
    # but for now I wrote the code so we have a syntax for parsing and working with nodes.
     	
	if nodestatus.empty?
		nodestatus = create_node_status_from_ship 
	end
    
    #@logic_nodes = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
    @logic_nodes = Array.new
    

	splitNodestatus = nodestatus.split("$")
        
    splitNodestatus.each do |nodeStatus|
      nodeSplit = nodeStatus.split(";")
            
      pos = S_Position.new(Integer(nodeSplit[2].split(",")[0]), Integer(nodeSplit[2].split(",")[1]))
          
      pushNode = nil
      
      case nodeSplit[1]
        when NodeTypeDef::N_AIRLOCK_ACTIVATOR then pushNode = N_Airlock_Activator.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3], nodeSplit[4])
        when NodeTypeDef::N_CONTROL_PANEL     then pushNode = N_Control_Panel.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3], nodeSplit[4])
        when NodeTypeDef::N_ENGINE            then pushNode = N_Engine.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3], nodeSplit[4])
        when NodeTypeDef::N_GENERATOR         then pushNode = N_Generator.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3], nodeSplit[4])
        when NodeTypeDef::N_WATER_CONTAINER   then pushNode = N_Water_Container.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3], nodeSplit[4])
        else                                       pushNode = N_Nil.new(nodeSplit[0], pos, nodeSplit[1], nodeSplit[3], nodeSplit[4])
      end
              
      @logic_nodes[pushNode.id.to_i] = pushNode
      
    end
  end

  def logEntryForNode(node)
    case node[:type]
    when NodeTypeDef::N_GENERATOR
      "Generators outputting at "+(node[:status]/node[:count]*100).round.to_s+"%. Energy reserves at "+(node[:health]/node[:count]*100).round.to_s+"%."
    when NodeTypeDef::N_ENGINE
      "Engines operating at "+(node[:health]/node[:count]*100).round.to_s+"%."
    when NodeTypeDef::N_WATER_CONTAINER
      "Water Tanks at "+(node[:health]/node[:count]*(node[:count]*AppConfig::WATER_FULL_TANK)).round.to_s+" of "+(node[:count]*AppConfig::WATER_FULL_TANK).round.to_s+" "+ AppConfig::WATER_UNIT+"(s) ("+((node[:health]/node[:count])*100).round.to_s+"%)."
    when NodeTypeDef::N_AIRLOCK_ACTIVATOR
      returnString = ""

      if(node[:status]==1) then
        returnString = "Airlock module is operational. Diagnostics show "
        
        if node[:health] == 1 then
          returnString += "no structural damage."
        elsif node[:health] > 0.8 then
          returnString += "some structural damage."
        elsif node[:health] > 0.4 then
          returnString += "structural damage. "
        else
          returnString += "heavy strucutral damage. Breakdown imminent."
        end

      else
        returnString = "Airlock module non-functional."
      end

      returnString
    else
      return "["+node[:type]+"] "+node[:count].to_s+" nodes. Status: "+node[:status].to_s+", Health: "+node[:health].round(2).to_s
    end

  end
  
  def drainWater(delta_water)
    @logic_nodes.each_index do |index|
      case @logic_nodes[index].node_type
      when NodeTypeDef::N_WATER_CONTAINER
        if @logic_nodes[index].health.to_f > 0 then
          @logic_nodes[index].health = (@logic_nodes[index].health.to_f - delta_water).to_s

          if @logic_nodes[index].health.to_f < 0 then
            delta_water = @logic_nodes[index].health.to_f.abs

            @logic_nodes[index].health = "0"
          else
            delta_water = 0
          end

        end

        if delta_water < 0 then break end
      end
    end
  end
  
  def create_node_status_from_ship
    setup_ship(@ship_id)
    
    id = 0
    nodestatusString = ""
    
    @nodes.each do |node|
      #id; x,y; health; status$
      nodestatusString += String(id)+";"+node.node_type+";"+String(node.position[:x])+","+String(node.position[:y])+";1;1$"
      id+=1
    end
    
    return nodestatusString
  end
  
  def build_nodestatus_string
    # :id, :position, :node_type, :health, :status

    tempString = ""
    
    #id; type; x,y; health; status$
    @logic_nodes.each do |node|
      tempString += node.id.to_s + ";" + node.node_type.to_s + ";" + node.position.x.to_s + "," + node.position.y.to_s + ";" + node.health.to_s + ";" + node.status.to_s + "$"
    end
    
    return tempString
  end
  
  def get_node_by_id(id)
    return @logic_nodes[id]
  end
  
  def parse_game_ship_from_ship
    @rooms  = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
        
    tempShip = getTempShip
    splitShip = tempShip.split("$")
    
		#splitShip = @ship.layout.split("$")
    
    splitShip.each do |room|
		splitRoom = room.split(";")
		
		# First we get the position
		pos = S_Position.new(Integer(splitRoom[0].split(",")[0]), Integer(splitRoom[0].split(",")[1]))

		# Then we get the access codes
		access = S_Access.new(String(splitRoom[1][0]), String(splitRoom[1][1]), String(splitRoom[1][2]), String(splitRoom[1][3]))
                  
		# Lets put it in our hash (-That's what SHE said!) 
		# make sure that its legit before putting it in. Heh.
		
		if(splitRoom[2] != "") then
			@rooms[pos.x.to_i][pos.y.to_i] = Room.new(pos, access, splitRoom[2])      
		end
    end
  end
  
  def parse_nodes_from_ship
    @nodes  = Array.new

    tempShip = getTempShip
    splitShip = tempShip.split("$")
    
    #splitShip = @ship.layout.split("$")
    
    splitShip.each do |room|
      splitRoom = room.split(";")
      
      pos = S_Position.new(Integer(splitRoom[0].split(",")[0]), Integer(splitRoom[0].split(",")[1]))
       
      # Parse the nodes into an array.    
      if !splitRoom[3].nil? then
        @nodes.push(Ship_Node.new(pos, splitRoom[3]))
      end
    end        
  end
  
  def whereCanIMoveFromHere?(pawn)
    # Future code here should take into account access levels
    # @rooms[pawn.x][pawn.y].access[:north]
    
    #allowedMoves = S_Access.new(0, 0, 0, 0)
    allowedMoves = Hash[:north => 0, :south => 0, :east => 0, :west => 0]   
    if @rooms[pawn.x][pawn.y-1].kind_of? Room then
      #There's a room north
      unless @rooms[pawn.x][pawn.y].access[:north].to_s == "x"
        allowedMoves[:north] = 1   
      end
    end
 
    if @rooms[pawn.x][pawn.y+1].kind_of? Room then
      #There's a room south
      unless @rooms[pawn.x][pawn.y].access[:south].to_s == "x"
        allowedMoves[:south] = 1   
      end
    end
      
    if @rooms[pawn.x-1][pawn.y].kind_of? Room then
      #There's a room west
      unless @rooms[pawn.x][pawn.y].access[:west].to_s == "x"
        allowedMoves[:west] = 1   
      end
    end
 
    if @rooms[pawn.x+1][pawn.y].kind_of? Room then
      #There's a room east
      unless @rooms[pawn.x][pawn.y].access[:east].to_s == "x"
        allowedMoves[:east] = 1   
      end
    end
    
    # Return
    return allowedMoves
  end
  
  def somethingInteractiveHere?(virtualPawn)
    #unless @logic_nodes[virtualPawn.x][virtualPawn.y].kind_of? LogicNode then return nil else return @logic_nodes[virtualPawn.x][virtualPawn.y] end
    
    @logic_nodes.each do |node| 
      if  virtualPawn.x == node.position.x &&
          virtualPawn.y == node.position.y then
          
          return node
      
      end      
    end
    
    return nil
  end
  
  def JSON_formatForResponse
    #setup_ship(@ship_id)
    
    toJSONResponse = Hash.new
    
    toJSONResponse[:name] = @ship.name
    
    json_rooms = @rooms
	
    @logic_nodes.each do |node|	
		json_rooms[node.position.x][node.position.y].node = node
    end
    
    toJSONResponse[:map] = json_rooms
    
    return toJSONResponse
  end
  
  def isThisARoom?(grid)
  	unless @rooms[grid.x].nil? then
  		@rooms[grid.x].each do |room|
  			if(room[1].position.y == grid.y) then
  				if room[1].kind_of? Room then
  					return true
  				end
  			end
  		end
  		
  		return false
  	else
  		return false
  	end
  end
end

class Room
  def initialize(pos, access, room_type)
    @position   = pos
    @access     = access
    @room_type  = room_type
	@seen = nil
	
	@possibleactions = Array.new()
	@possibleactions.push(nil)
  end

  attr_accessor :position, :access, :room_type, :node, :seen, :possibleactions
end

class Ship_Node
  def initialize(pos, node_type)
    @position   = pos
    @node_type  = node_type
  end
  
  attr_accessor :position, :node_type
end

class LogicNode
  attr_accessor :id, :position, :node_type, :health, :status

  def initialize(id, pos, node_type, health, status)
    @id = id
    @position   = pos
    @node_type  = node_type
    @health = health
    @status = status
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
