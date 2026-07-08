return function (list)
  for i = #list, 1, -1 do
    local j = math.random(1, #list)
    print(string.format("i: %d, j: %d", i, j))

    list[i], list[j] = list[j], list[i]
  end
end
