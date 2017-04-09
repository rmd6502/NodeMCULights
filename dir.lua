for f,s in pairs(file.list()) do print (f..": "..s) end
remaining, used, total=file.fsinfo()
print(remaining.." bytes free of "..total)
