return {
  ['>'] = { 2, function(x, y) return x < y end },
  ['+'] = { 2, function(x, y) return x + y end },
  att = { 0, function() print('ATT') end },
  esc = { 1, function(v) io.write('logo> '); p(v) end },
}

-- vim: ts=2:sw=2:sts=2:expandtab
