def Bench.run
  i = 0
  while @should_run
    # string#rindex(...)
    raise "string#rindex(...) benchmark is not implemented"
    i += 1
  end

  @iterations = i
end
