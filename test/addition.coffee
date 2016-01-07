expect = require('should')
require('./extend')
V = require('../src/validator')

# $required
rule =
  a: 'Number:required'
  $required:
    b: 'Number'

trueObj =
  a: 8
  b: 8

falseObj1 =
  b: 8

falseObj2 =
  a: 8

expect(V.check(rule, trueObj)[0]).equal(true)
expect(V.check(rule, falseObj1)[0]).equal(false)
expect(V.check(rule, falseObj2)[0]).equal(false)

# $empty
rule =
  a: 'Number:empty'
  b: 'Number:empty'
  $empty:
    c: 'Number'

trueObj =
  a: ''
  b: []
  c: {}

expect(V.check(rule, trueObj)[0]).equal(true)

# $null
rule =
  a: 'Number:null'
  $null:
    b: 'Number'

trueObj =
  a: null
  b: null

expect(V.check(rule, trueObj)[0]).equal(true)

