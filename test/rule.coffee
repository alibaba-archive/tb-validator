require('./extend')
V = {Rule, RuleSet, Path} = require('../src/validator')

rule1 =
  "str": "String:required"
  $or:
    a: "String:required"
    b: "Number:required"
    c: $array: "Number:required"

obj1 =
  str: 12
  a: 'asd'
  b: 6
  c: [9,8,'as']

console.log V.check(rule1, obj1)