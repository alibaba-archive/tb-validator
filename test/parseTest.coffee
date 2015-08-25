v = require('../src/validator')

rule = subtaskIds: $array: 'ObjectId:empty'
parsed = v.parse(rule)
console.log parsed