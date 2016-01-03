local embracer = {}

local function helper()
   -- NYI wontfix
end

function embracer.embrace(opt)
   opt = opt or "default"
   return helper(opt.."?")
end

function embracer:x() -- luacheck: ignore self
end

return embracer
