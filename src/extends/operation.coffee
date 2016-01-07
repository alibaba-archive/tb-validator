_ = require('lodash')
Base = require('./extend')

OPERATIONS =

  $in: (target, arr) ->
    return target in arr

  $eq: _.isEqual

  $neq: ->
    return not _.isEqual.apply(_, arguments)

module.exports = new Base
  Data: OPERATIONS
  check: (arr, op) ->
    for key, val of op
      handler = @get(key)
      return false unless handler
      handler = _.partial handler, _, val
      return _.reduce _.map(arr, handler), (a, b) ->
        return a and b