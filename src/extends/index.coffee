typeEx = require('./type')
additionEx = require('./addition')
operationEx = require('./operation')
logicEx = require('./logic')
u = require('../util')

OPKEY = 'operation'
ADKEY = 'addition'
TYKEY = 'type'
LGKEY = 'logic'

module.exports = Extends = {}
Extends[OPKEY] = operationEx
Extends[ADKEY] = additionEx
Extends[TYKEY] = typeEx
Extends[LGKEY] = logicEx

fns = ['has', 'extend', 'get', 'include']

fns.forEach (key) ->
  Extends[key] = (type) ->
    return false unless @[type]
    args = u.slice(arguments, 1)
    @[type][key].apply(@[type], args)