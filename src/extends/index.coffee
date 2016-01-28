u = require('../util')

module.exports = Extends = {}
Extends['operation'] = require('./operation')
Extends['alias'] = require('./alias')
Extends['type'] = require('./type')
Extends['logic'] = require('./logic')

fns = ['has', 'extend', 'get', 'include']

fns.forEach (key) ->
  Extends[key] = (type) ->
    return false unless @[type]
    args = u.slice(arguments, 1)
    @[type][key].apply(@[type], args)