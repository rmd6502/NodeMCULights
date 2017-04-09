  args={...}
  for idx = 1,#args do
    fd=file.open(args[idx])
    if fd ~= nil then
      while true do
        line=fd:read()
        if line == nil then
          break
        end
        print(line)
      end
      fd:close()
    end
  end
