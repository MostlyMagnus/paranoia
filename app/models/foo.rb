# action queue



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
	attr_accessor :PRIO
	
	def initialize(prio=0)
		@PRIO = prio
	end
	
end

class NOP < Action
	
	def initialize(prio=0)
		super(prio)
	end
	
	def to_s
		"A: NOP (#{@PRIO})"
	end
end

class KILL < Action
	
	def initialize(prio=-100)
		super(prio)
	end
		
	def to_s
		"A: KILL (#{@PRIO})"
	end
end

class Move < Action
	attr_accessor :prev_pos, :move_pos
	
	def initialize(prev_pos, move_pos, prio=50)
		super(prio)
		@prev_pos = prev_pos
		@move_pos = move_pos
    end
	
	def to_s
		"A: MOVE #{prev_pos} -> #{move_pos} (#{@PRIO})"
	end
end

acts = [Move.new(Pos.new(1,2), Pos.new(1,3))]
acts.push(NOP.new)
acts.push(KILL.new)
acts.push(NOP.new)

acts.each do |t|
	puts t.PRIO
end

acts.sort! { |a,b| a.PRIO <=> b.PRIO } # <-FRAKKIN SPACESHIP
puts acts

class ActionQueue < Array
	
	def push(action)
		if action.kind_of? Action
			super
		else
			raise "Only actions (and kind_of actions) can be placed in actionqueues, please reconsider"
		end
		
	end
end
