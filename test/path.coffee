expect = require('should')
resolvePath = require('../src/util').resolvePath

obj =
  a: [{
    b: [{
      c: [{
        test: 1
      },{
        test: 2
      },{
        test: 3
      }]
    },{
      c: [{
        test: 1
      },{
        test: 2
      },{
        test: 3
      }]
    }]
  },{
    b: [{
      c: [{
        test: 1
      },{
        test: 2
      },{
        test: 3
      }]
    },{
      c: [{
        test: 1
      },{
        test: 2
      },{
        test: 3
      }]
    }]
  }]

res = resolvePath('a.$array.b.$array.c.$array.test', obj)
expect(res.length).equal(12)

res = resolvePath('a.$array.b.$array.c.$array', obj)
expect(res.length).equal(12)
expect(res[0].test).equal(1)

res = resolvePath('a.0.b.0.c.0.test', obj)
expect(res).equal(1)