return function (list)
  for i = #list, 1, -1 do
    local j = math.random(1, #list)
    list[i], list[j] = list[j], list[i]
  end
end
