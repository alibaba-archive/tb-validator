expect = require('should')
require('./extend')
V = require('../src/validator')

andRule =
  $and:
    a: "String:required"
    b: "Number:required"
    c: "Number:required"
  $or:
    d: "Number:required"
    f: "Number:required"
    g: "Number:required"

andFalse =
  str: 12
  a: 'asd'
  b: 6
  c: 'as'
  d: 'as'
  f: 'as'

# expect(V.check(andRule, andFalse)[1]).equal(false)
console.log V.check(andRule, andFalse)[1]