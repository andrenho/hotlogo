require 'helper/strict'
require 'helper/classes'
require 'helper/functional'
require 'helper/inspect'

require 'primitives'
require 'environment'

-- 
-- TYPES
--

Lambda = class()
function Lambda:__init(parameters, body)
  self.parameters = parameters
  self.body = body
end

--
-- ERRORS (TODO)
--
function logo_error(s)
  error(s)
end

-- 
-- EVAL
--

env = Environment()


function eval(exp)

  -- string
  if type(exp) == 'string' then
    local n = env.get(exp)
    --if not n then logo_error('Variable "'..exp..'" not bound.') end
    if n then return n else return exp end

  -- numeric
  elseif type(exp) == 'number' then
    return exp

  -- list
  elseif type(exp) == 'table' then

    -- lambda
    if exp[1] == 'lambda' then
      if #exp ~= 3 then
        logo_error('Invalid number of arguments for lambda')
      end
      return Lambda(exp[2], exp[3])

    -- apply
    else
      pp = {}
      for _,n in ipairs(exp) do pp[#pp+1] = eval(n, env) end
      f = table.remove(pp, 1)  -- extract function
      return apply(f, pp)
    end

  end

  logo_error('Invalid expression: '..inspect(exp))
end


function apply(f, pars)
  if type(f) == 'string' then
    local p = primitives[f]
    if p then
      return p.code(table.unpack(pars))
    else
      error(inspect(f)..' not a primitive.') -- TODO - deal with that later
    end
  elseif f.is_a and f.is_a[Lambda] then
    if #pars ~= #f.parameters then
      logo_error('The number of parameters and arguments on lambda don\'t match: '..inspect(f))
    end
    env.push()
    for i=1,#pars do env.set(f.parameters[i], pars[i]) end
    local r = eval(f.body)
    env.pop()
    return r
  end
end


-- 
-- test code
--

p(eval({ '+', 20, 30 }))
p(eval({ 'lambda', { 'x', 'y' }, { '+', 'x', 'y' } }))
p(eval({ { 'lambda', { 'x', 'y' }, { '+', 'x', 'y' } }, 30, 40 }))
--print(eval(Lambda({ 'x', 'y' }, { { '+', Variable('x'), Variable('y') } })))
--print(eval({ Lambda('x', 'y'), { Function('+'), Variable('x'), Variable('y') }, 30, 40 }, env))


-- vim: ts=2:sw=2:sts=2:expandtab
