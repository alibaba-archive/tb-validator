_ = require('lodash')
Base = require('./extend')
RESULT = require('../result')

# 空字符串 空对象 空数组则返true
isEmpty = (obj) ->
  if _.isArray(obj) and obj.length is 0
    return true
  if _.isPlainObject(obj)
    return true
  if obj is ''
    return true
  return false

ADDITIONS =

  $required: (target, required, r) ->
    if required and _.isUndefined target
      return r.UNVALID
    else if !required and _.isUndefined target
      return r.VALID
    else
      return r.PASS

  $empty: (target, empty, r) ->
    if not empty and _.isEmpty target
      return r.UNVALID
    else if empty and _.isEmpty target
      return r.VALID
    else
      return r.PASS

module.exports = new Base
  Data: ADDITIONS
  check: (target, addition) ->
    for key, val of addition
      handler = @get(key)
      return false unless handler
      unless _.isArray(target)
        target = [target]
      handler = _.partialRight handler, _, val, RESULT
      rt = _.reduce _.map(target, handler), (a, b) ->
        return a or b
      if rt is RESULT.PASS
        continue
      else
        return rt
