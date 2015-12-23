expect = require('should')
V = require('../src/validator')
require('./extend')

rule =
  yes: 'String:required:empty'

data1 =
  yes: 'yes'

data2 =
  yes: 12

data3 = {}

data4 =
  yes: ''

expect(V.checkRule(data1, rule)[1]).equal(true)
expect(V.checkRule(data2, rule)[0][0]['err'][0]).equal('$type')
console.log V.checkRule(data3, rule)
expect(V.checkRule(data3, rule)[0][0]['err']).equal('$required')
expect(V.checkRule(data3, rule)[1]).equal(true)

# addtion test

rule =
  str: 'String:required:empty:null'
  use:
    $in: ['how', 'are', 'you']

