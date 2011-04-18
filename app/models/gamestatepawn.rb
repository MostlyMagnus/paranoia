class GamestatePawn
  def initialize(pawn_id, x, y, status)
    @pawn_id = pawn_id
    @x = x
    @y = y
    @status = status
  end
  
  attr_accessor :pawn_id, :x, :y, :status
end