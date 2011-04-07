

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
file = File.new("ships/test.sid", "r")
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
	else
		tmp = tmp + i
	end
end

puts cnt


