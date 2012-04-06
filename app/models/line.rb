class Line < ActiveRecord::Base
	belongs_to :pawn

	def name(level)
		Persona.find_by_id(Pawn.find_by_id(self.pawn_id).persona_id).name
	end

	def scramble(level)
		self.text	
	end
end
