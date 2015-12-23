{ isFunction, isString, isObject, isArray } = _ = require('lodash')
{ argsWrap } = require('../util')

class Extend

  constructor: (opts) ->
    opts or= {}
    for key, val of opts
      if isFunction val
        @[key] = _.bind val, @
      else
        @[key] = val
    @

  Data: {}

  THIRDS: []

  has: (key) ->
    return !!@Data[key] if @Data[key]
    for third in @THIRDS
      if third[key]
        return !!third[key]
    return false

  extend: argsWrap((key, fn) ->
    return unless isFunction(fn) and isString(key)
    @Data[key] = fn
  )

  get: (key) ->
    return @Data[key] if @Data[key]
    for third in @THIRDS
      if third[key]
        return third[key]
    return null

  include: (third) ->
    return unless isObject(third)
    @THIRDS.push third

  getKeyFromStr: (str) ->
    keys = Object.keys(@Data)
    for key in keys
      if str.indexOf(key) is 0
        return key
    return null

module.exports = Extend

