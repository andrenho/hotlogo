Primitive = class()
function Primitive:__init(n_parameters, code)
  self.n_parameters = n_parameters
  self.code = code
end

primitives = {
  ['+'] = Primitive(2, function(x, y) return x + y end),
  att = Primitive(0, function() return 'ATT' end),
}

-- vim: ts=2:sw=2:sts=2:expandtab
