
local main_id = arg[1] -- get s the m a in tas k id   fro m ar g[ 1]
while true do
     local buf, flags, rc = task.receive ( -1) --  wait s for me s s a g e
     if flags == 1 then
          break −− if fla gs is st op, ter m i n a t e s
     else
          task.post ( main_id, 'Echo: {' .. buf .. '}', 0) -- sen d s ec h o
     end
end
task.post ( main_id, '', 1) -- sen d s ac k n o w l e d g e   for sto p me s s a g 