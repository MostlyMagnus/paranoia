

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

levelname = 'test level'

print levelname

cnt = 0
file = File.new("test.sid", "r")
while (line = file.gets)
	puts "#{cnt}; #{line}"
	cnt = cnt + 1
end
file.close
