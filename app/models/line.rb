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
		
		if level <= 1 then
			self.text
		else 			
			# Define the string which should be applied by the pattern. The user will see this.
			muffledString = "[...]"

			# Define the pattern for scrambling the text.
			if level == 2 then
				pattern = Array.new([muffledString, nil, nil]*20)
			elsif level == 3 then
				pattern = Array.new([muffledString, muffledString, muffledString, nil]*20)
			elsif level == 4 then
				pattern = Array.new([muffledString]*20)
			end

			# Getting ready to apply the pattern.
			splitString = self.text.split
			wordCount = self.text.split.size - 1

			# Apply the pattern.

			# Loop for every word in the splitString array.
			for i in 0..wordCount
				# If the pattern marker isn't nil, we should scramble this word.
				if(pattern[i] != nil) then
					# Salt is a word marker that was randomly picked when the user heard this.
					splitString[salt] = pattern[i]
				end

				# Lets step forward through the sentence.
				salt += 1

				# We've reached the end of the sentence, but chances are we havent gone through
				# the entire thing.
				if salt > wordCount then
					# Reset the salt marker
					salt = 0
				end
			end

			# Pattern has been applied. Merge any adjacent muffledStrings.
			for i in 0..splitString.size()-1
				# We're currently at a muffledString.
				if splitString[i] == muffledString then
					# As long as the next one is a muffled string, delete it.
					while(splitString[i+1] == muffledString) do
						splitString.delete_at(i+1)
					end								
				end
			end

			# Join the array into a string and return it.
			splitString.join(" ")
		end		
	end
end
