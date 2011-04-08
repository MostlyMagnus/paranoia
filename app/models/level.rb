

=begin
 Access codes:
   nwse (north, west, south, east) 
 x = no access
 r = same room
 0 = open access
 1 = door
 2 = door access lv 2
 3 = door access lv 3
 
 Rooms
 G1 = generic 1
 C1 = corridor 1
=end

#for n in rooms
#      puts n
#end

class Room

end

class Level
	attr_accessor :lvl_str, :rooms

	def initialize(str)
		@lvl_str = str
		@rooms = Array.new
		tmp = ""
		str.each_char do |ch|
			if ch.eql? "\["
				next
			elsif ch.eql? "\]"
				@rooms.push(tmp)
				tmp = ""
			else
				tmp << ch
			end
		end
	end

	def to_s
		@lvl_str
	end
end


def load_ship_from_file(f)
	name = ""
	while (line = f.gets)
		if line.match("^name=")
			name = line[line.index("\"")+1,line.length]
			name = name[0, name.index("\"")]
		elsif line.match("^level=")
			level = line[line.index("["), line.length-1]
			puts level
		end
	end
	f.close
end

file = File.new("../../devel_ships/ship1.sid", "r")
load_ship_from_file(file)
