expect = require('should')
require('./extend')
V = require('../src/validator')

rule =
  a: (target) ->
    console.log target
    if target is undefined
      return true
    if target is null
      return false
    return !!target.length

objTrue =
  a: undefined

objFalse1 =
  a: []

objFalse2 =
  a: null

expect(V.check(rule, objTrue)[0]).equal(true)
expect(V.check(rule, objFalse1)[0]).equal(false)
expect(V.check(rule, objFalse2)[0]).equal(false)