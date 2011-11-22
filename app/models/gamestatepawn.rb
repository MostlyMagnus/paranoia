class GamestatePawn
  def initialize(pawn_id = 0, x = 0, y = 0, status = 0, persona = nil)
    @pawn_id = pawn_id
    @x = x
    @y = y
    @status = status
    @persona = persona
  end
  
  def sanitize
    @x, @y = nil, nil
  end
  
  attr_accessor :pawn_id, :x, :y, :status, :persona
end