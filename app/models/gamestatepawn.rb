class GamestatePawn
  def initialize(pawn_id = 0, x = 0, y = 0, status = 0)
    @pawn_id = pawn_id
    @x = x
    @y = y
    @status = status
  end
  
  attr_accessor :pawn_id, :x, :y, :status
end