class Room
	attr_accessor :x, :y, :paths, :type, :nodes
		
	# should remove []s
	def initialize(s)
		@x = s[0,s.index( "," )]
		s = s[s.index("," ) + 1, s.length - 1]
		
		@y = s[0,a.index(";")]
		s = s[s.index( ";" ) + 1, s.length - 1]
		
		@paths = s[0,4]
		s = s[s.index(";") + 1, s.length - 1]
		
		@type = s[0,s.index( ";" ) ]
		s = s[s.index(";") + 1, s.length - 1]
		
		@nodes = Array.new
		while s.length > 0
			if not s.index( "," )
				@nodes.push(s[0, s.length - 1 ])
				s = ""
			else
				@nodes.push(s[0, s.index( "," )])
				s = s[s.index("," ) + 1, s.length - 1] 
			end
		end
	end
	
	def to_s
		"pos: #{x},#{y}\npaths: #{paths}\n"
	end
	
end