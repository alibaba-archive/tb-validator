require('./extend')
V = {Rule, RuleSet, Path} = require('../src/validator')

rule1 = [
  a: 'String'
  b: 'Number'
,
  a: 'String'
  b: 'Number'
]

obj1 = [
  a: 'as'
  b: 1
,
  a: 'as'
  b: 1
]

expect(V.check(rule1, obj1)[0]).equal(true)