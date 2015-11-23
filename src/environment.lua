Environment = class()

function Environment:__init()
  self.values = {}
end

function Environment:push()
end

function Environment:pop()
end

function Environment:set(k, v)
  --self.values[k] = v
end

function Environment:get(v)
  --return self.values[k]
end

-- vim: ts=2:sw=2:sts=2:expandtab
