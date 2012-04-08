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

	def scramble(level)
		self.text	
	end
end
