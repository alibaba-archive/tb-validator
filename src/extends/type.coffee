_ = require('lodash')
Base = require('./extend')
TYPES = {}
THIRDS = []

module.exports = new Base
  Data: TYPES
  THIRDS: THIRDS
  check: (arr, type) ->
    handler = @get(type)
    return false unless handler
    return _.reduce _.map(arr, handler), (a, b) ->
      return a and b