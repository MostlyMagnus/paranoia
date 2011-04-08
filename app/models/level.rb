require 'room.rb'

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

cnt = 0
file = File.new("../debug_levels/test.sid", "r")
name = "N/A"
level = ""
while (line = file.gets)
	if line[/^level=/]
		level = line
	elsif line[/^name=/]
		name = line
	end
end
file.close

name = name[name.index("\"")..-1].chomp
level = level[level.index("\[")..-1].chomp

#puts "Name: #{name}\nlevel: #{level}"

rooms = Array.new
tmp = ""
cnt = 0
level.each_char do |i|
	if i.eql? "\["
		cnt = cnt + 1
	elsif i.eql? "\]"
		rooms.push(tmp)
		tmp = ""
	else
		tmp = tmp + i
	end
end

#for n in rooms
#	puts n
#end

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
test_level = Level.new(level)
puts test_level

=begin
class Ship
	#attr_accessor 
	
	def initialize( s )
end
=end


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
x = Pos.new(1,2)

#class Player
#end 


