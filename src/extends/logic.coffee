_ = require('lodash')
u = require('../util')
Base = require('./extend')

DATA =

  $and: ->
    args = u.slice(arguments)
    return _.reduce(args, (a, b) ->
      return a and b
    )

  $or: ->
    args = u.slice(arguments)
    return _.reduce(args, (a, b) ->
      return a or b
    )

  $xor: ->
    args = u.slice(arguments)
    return _.reduce(args, (a, b) ->
      return a ^ b
    )

module.exports = new Base
  Data: DATA
  has: (str) ->
    return false unless str
    keys = Object.keys(@Data)
    for key in keys
      if str.indexOf(key) is 0
        return true
    return false