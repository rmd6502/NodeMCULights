  args={...}
  for idx = 1,#args do
    fd=file.open(args[idx])
    if fd ~= nil then
      while true do
        line=fd:readline()
        if line == nil then
          break
        end
        line = line:gsub("[\r\n]"," ")
        print(line)
      end
      fd:close()
    end
  end
