expect = require('should')
require('./extend')
V = require('../src/validator')

andRule =
  $and:
    a: "String:required"
    b: "Number:required"
    c: "Number:required"

andTrue =
  str: 12
  a: 'asd'
  b: 6
  c: 9

andFalse =
  str: 12
  a: 'asd'
  b: 6
  c: 'as'

expect(V.check(andRule, andTrue)[0]).equal(true)
expect(V.check(andRule, andFalse)[0]).equal(false)

orRule =
  $or:
    a: "String:required"
    b: "Number:required"
    c: "Number:required"

orTrue =
  str: 12
  a: 2
  b: 'asd'
  c: 9

orFalse =
  str: 12
  a: 2
  b: 'as'
  c: 'as'

expect(V.check(orRule, orTrue)[0]).equal(true)
expect(V.check(orRule, orFalse)[0]).equal(false)

xorRule =
  $xor:
    a: "String:required"
    b: "Number:required"
    c: "Number:required"

xorTrue =
  str: 12
  a: 2
  b: 'asd'
  c: 9

xorFalse1 =
  str: 12
  a: 2
  b: 'as'
  c: 'as'

xorFalse2 =
  str: 12
  a: 2
  b: 2
  c: 2

expect(V.check(xorRule, xorTrue)[0]).equal(true)
expect(V.check(xorRule, xorFalse1)[0]).equal(false)
expect(V.check(xorRule, xorFalse2)[0]).equal(false)

