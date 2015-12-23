_ = require('lodash')
Base = require('./extend')
TYPES = {}
THIRDS = []

module.exports = new Base
  Data: TYPES
  THIRDS: THIRDS
  check: (target, type) ->
    handler = @get(type)
    return false unless handler
    unless _.isArray(target)
      target = [target]
    return _.reduce _.map(target, handler), (a, b) ->
      return a and b