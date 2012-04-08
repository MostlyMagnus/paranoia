class Line < ActiveRecord::Base
	belongs_to :pawn

	def name(level)
		if(level > 0) then 
			"Unknown"
		else
			Persona.find_by_id(Pawn.find_by_id(self.pawn_id).persona_id).name
		end
	end

=begin 

Scrmb	Distance of		Example
0		LOS				[L.Bronson] 	The brown fox jumped over the lazy dog.
1		<2				[Someone]  		The brown fox jumped over the lazy dog.
2		<3				[Someone]  		[muffled] brown fox [muffled] over the [muffled] dog.
										1 4 7
3		<4				[Someone]  		[muffled] jumped [muffled] dog.		
										1-3 5-7
4		<6				[Someone]		[muffled]

=end

	def scramble(level, salt = 1)
		muffledString = "[muffled]"
		if level <= 1 then
			self.text
		else # level == 2 then
			pattern = Array.new([muffledString, nil, nil]*10)
			
			splitString = self.text.split
	
			for i in 0..string.split.size
				if(pattern[i] != nil) then
					splitString[salt] = pattern[i]
				end

				salt += 1
				if salt > string.split.size then
					salt -= string.split.size
				end
			end

		#elsif level == 3 then
		#elsif level == 4 then
		#	muffledString
		end		
	end
end
