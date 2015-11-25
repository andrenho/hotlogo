Environment = {
  stack = { {} },
  current = 1,
}

function Environment:new()
  e = {}
  setmetatable(e, self)
  self.__index = self
  -- load primitives
  for k,v in pairs(require('primitives/primitives')) do 
    self:add_primitive(k, v[1], v[2]) 
  end
  return e
end

function Environment:push()
  self.current = self.current + 1
  self.stack[self.current] = {}
end

function Environment:pop()
  table.remove(self.stack, self.current)
  self.current = self.current - 1
end

function Environment:set(k, v)
  for i=self.current,1,-1 do
    if self.stack[i][k] then 
      self.stack[i][k] = v 
      return
    end
  end
  self.stack[self.current][k] = v  -- not found, set into the highest stack level
end

function Environment:get(k)
  for i=self.current,1,-1 do
    if self.stack[i][k] then 
      return self.stack[i][k]
    end
  end
  return nil
end

function Environment:add_primitive(name, n_pars, code)
  assert(not self.stack[1][name], name..' already exists as a primitive')
  assert(type(name) == 'string')
  assert(type(n_pars) == 'number')
  assert(type(code) == 'function')
  self.stack[1][name] = { tag='primitive', n_pars=n_pars, code=code }
end


-- vim: ts=2:sw=2:sts=2:expandtab
