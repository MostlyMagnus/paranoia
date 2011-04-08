# action queue

class ActionQueue < Array
	attr_accessor :q
	
	def push(action)
		#if action.kind_of? action
		if true #insert check for proper action object
			puts "ok!?"
		else
			puts "error" #yeah, needs proper error laters
		end
		
	end
	
	
end
v = ActionQueue.new
puts v.push(1)


class Pos
	attr_accessor :x, :y
	
	def initialize(x, y)
		@x = x
		@y = y
	end
	
	def to_s
		"(#{x},#{y})"
	end
end

class Action
	NOP = 0
	REPAIR = 1
	INTEROG = 2
	KILL = 3
	MOVE = 4
end

class NOP < Action
	def to_s
		"Action:NOP"
	end
end

class Move < Action
	attr_accessor :prev_pos, :move_pos
	
	def initialize(prev_pos, move_pos)
		@prev_pos = prev_pos
		@move_pos = move_pos
    end
	
	def to_s
		"Action:Move #{prev_pos} -> #{move_pos}"
	end
end
m1 = Move.new(Pos.new(1,2), Pos.new(1,3))
puts m1
nop = NOP.new
puts nop
puts nop.kind_of? Action

=begin
=end
class Move
	attr_accessor :prev_pos, :move_pos, :action
		

end