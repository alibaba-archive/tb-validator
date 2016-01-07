expect = require('should')
require('./extend')
V = require('../src/validator')

# $in

rule =
  a: $in: [1,2,3,null]

trueObj =
  a: null

falseObj =
  a: ''

expect(V.check(rule, trueObj)[0]).equal(true)
expect(V.check(rule, falseObj)[0]).equal(false)

# $eq
