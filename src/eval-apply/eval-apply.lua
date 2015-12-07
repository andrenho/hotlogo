require 'extra/strict'
require 'extra/helper/functional'
require 'extra/helper/inspect'
require 'eval-apply/environment'

--
-- ERRORS (TODO)
--
function logo_error(s)
  error(s)
end

-- 
-- EVAL
--

env = Environment:new()


function eval(exp)

  -- string - try to find the symbol value, if not a symbol then returns self
  if type(exp) == 'string' then
    local n = env:get(exp)
    if n then return n else return exp end

  -- numeric
  elseif type(exp) == 'number' then
    return exp

  -- special types of lists
  elseif type(exp) == 'table' then

    -- lambda
    if exp[1] == 'lambda' then
      if #exp ~= 3 then logo_error('Invalid number of arguments for lambda') end
      return { tag='lambda', parameters=exp[2], body=exp[3] }

    -- definition
    elseif exp[1] == 'define' then
      if #exp ~= 3 then logo_error('Invalid number of arguments for define') end
      env:set(exp[2], eval(exp[3]))
      return nil

    -- quotation
    elseif exp[1] == 'quote' then
      local v = {}
      for i=2,#exp do v[#v+1] = exp[i] end
      return v

    -- if
    elseif exp[1] == 'if' then
      if #exp ~= 3 and #exp ~=4 then logo_error('Invalid number of arguments for if') end
      if eval(exp[2]) then
        return eval(exp[3])
      elseif exp[4] then
        return eval(exp[4])
      else
        return nil
      end

    -- regular list -- apply it!
    else
      local pp = {}
      for _,n in ipairs(exp) do pp[#pp+1] = eval(n, env) end
      f = table.remove(pp, 1)  -- extract function
      return apply(f, pp)

    end

  end

  logo_error('Invalid expression: '..inspect(exp))
end


--
-- APPLY
--

function apply(f, pars)
  if f.tag == 'primitive' then
    local r = f.code(table.unpack(pars))
    return r
  elseif f.tag == 'lambda' then
    if #pars ~= #f.parameters then
      logo_error('The number of parameters and arguments on lambda don\'t match: '..inspect(f))
    end
    env:push()
    for i=1,#pars do env:set(f.parameters[i], pars[i]) end
    local r; for _,part in ipairs(f.body) do r = eval(part) end
    env:pop()
    return r
  else
    logo_error('Can\'t apply '..inspect(f))
  end
end


-- 
-- test code
--

--[[
require 'extra/helper/functional'
require 'extra/helper/inspect'

p(eval { '+', 20, 30 })
p(eval { '+', { '+', 2, 3 }, 10 })

p(eval { 'lambda', { 'x', 'y' }, { { '+', 'x', 'y' } } })
p(eval { { 'lambda', { 'x', 'y' }, { { '+', 'x', 'y' } } }, 30, 40 })

eval { 'define', 'v', 42 }
eval { 'write', 'v' }

eval { 'define', 'sum', { 'lambda', { 'x', 'y' }, { { '+', 'x', 'y' } } } }
p(eval { 'sum', 2, 3 })

eval { 'write', { 'quote', 1, 2, 3 } }

eval { 'write', { 'if', { '>', { 'sum', 2, 3 }, 6 }, 'yes', 'no' } }
]]

-- vim: ts=2:sw=2:sts=2:expandtab
