const fs = require('fs')
const process = require('process')
const ReadLine = require('readline')
const Path = require('path')

const readStream = fs.createReadStream(process.argv[2])
const fileName = process.argv[3] || process.argv[2]

readStream.on('open', function () {
  console.log('fd=file.open("' + Path.basename(fileName) + '","w+")')
})

readStream.on('end', function () {
  console.log('fd:close()\n\n')
})

const reader = ReadLine.createInterface({
  input: readStream
})

reader.on('line', function (line) {
  line = line.replace(/\\/g, '\\\\')
  line = line.replace(/"/g, '\\"')
  console.log('fd:writeline("' + line + '")\r')
})
