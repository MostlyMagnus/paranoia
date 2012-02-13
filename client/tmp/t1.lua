require 'task'
local myid = task.id () -- get s the cu r r e n t tas k id
local tsk, err = task.create ('t2.lua', {myid}) -- cr e a t e s a ne w tas k
while true do
       io.stdout:write( '\necho> ') -- sh o w s pr o m p t
       local cmd = io.stdin.read( '*l') -- get s co m m a n d
       if cmd == 'quit' then
               break --if c o m m a n d is qu it , ter m in a t e s
       else
               task.post ( tsk, cmd, 0) --sen d s c o m m a n d te xt to ec h o tas k 
local buf, flags, rc = task.receive ( -1) -- wait s for an s w e r
               io.stdout:write( buf) -- sh o w s an s w e r
       end
end
task.post ( tsk, '', 1) -- sen d s du m m y m e s s a g e wit h "1" as st op fla g
task.receive(1000) -- wa it s (1 sec ) for sto p ac k n o w l e d g e fro m ec h o tas k