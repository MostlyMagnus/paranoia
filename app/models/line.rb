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
		muffledString = "[...]"
		if level <= 1 then
			self.text
		else 			
			splitString = self.text.split

			if level == 2 then
				pattern = Array.new([muffledString, nil, nil]*20)
			elsif level == 3 then
				pattern = Array.new([muffledString, muffledString, muffledString, nil]*20)
			elsif level == 4 then
				pattern = Array.new([muffledString]*20)
			end

			wordCount = self.text.split.size - 1
			for i in 0..wordCount
				if(pattern[i] != nil) then
					splitString[salt] = pattern[i]
				end

				salt += 1
				if salt > wordCount then
					salt -= wordCount
				end
			end

			mergedString = Array.new()

			for i in 0..splitString.size()-1
			
				if splitString[i] == muffledString then
					while(splitString[i+1] == muffledString) do
						splitString.delete_at(i+1)
					end								
				end

			end

			splitString.join(" ")
		end		
	end
end
