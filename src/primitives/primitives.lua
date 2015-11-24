return {
  ['>'] = { 2, function(x, y) return x < y end },
  ['+'] = { 2, function(x, y) return x + y end },
  write = { 1, function(v) p(v) end },
}

-- vim: ts=2:sw=2:sts=2:expandtab
