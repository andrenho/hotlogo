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


function eval(exp, debug)

  if debug then
    io.write("eval> ")
    p(exp)
  end

  if not exp then

    return nil

  -- string - try to find the symbol value, if not a symbol then returns self
  elseif type(exp) == 'string' then

    if exp == 'true' then
      return true
    elseif exp == 'false' then
      return false
    end

    local n = env:get(exp)
    if n then return n else return exp end

  -- boolean
  elseif type(exp) == 'boolean' then
    return exp

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

    -- begin
    elseif exp[1] == 'begin' then
      local r
      for i=2,#exp do r = eval(exp[i]) end
      return r

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
      for _,n in ipairs(exp) do pp[#pp+1] = eval(n) end
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
-- HELPER FUNCTIONS (for C)
--
function parameter_count(name)
  local f = env:get(name)
  if not f then
    return -1
  elseif f.tag == 'lambda' then
    return #f.parameters
  elseif f.tag == 'primitive' then
    return f.n_pars
  else
    return -1
  end
end

function add_temp_function(name, n_pars)
  local p = {}
  for i=1,n_pars do p[#p+1] = 0 end
  env:set(name, { tag='lambda', parameters=p })
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


--eval { 'esc', { 'if', { '>', { '+', 2, 3 }, 6 }, 'yes', 'no' } }
]]

--p(eval { 'quote', 1, 2, 3 })
--eval { 'begin', { 'esc', 1 }, { 'esc', 2 } }
--eval { 'if', true, { 'begin', { 'esc', 1 }, { 'esc', 3 } }, { 'begin', { 'esc', 2 } } }

-- eval { 'define', 'x', { 'lambda', {}, { 'begin', { 'x' } } } }

-- vim: ts=2:sw=2:sts=2:expandtab
