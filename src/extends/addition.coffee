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
    if not empty and isEmpty target
      return r.UNVALID
    else if empty and isEmpty target
      return r.VALID
    else
      return r.PASS

  $null: (target, canNull, r) ->
    isNull = _.isNull(target) or (_.isString(target) and target.toLowerCase() is 'null')
    if not canNull and isNull
      return r.UNVALID
    else if canNull and isNull
      return r.VALID
    else
      return r.PASS

module.exports = new Base
  Data: ADDITIONS
  format: (addition) ->
    Object.keys(@Data).forEach (key) ->
      addition[key] = addition[key] or false
  check: (arr, addition) ->
    @format(addition)
    for key, val of addition
      handler = @get(key)
      return false unless handler
      handler = _.partial handler, _, val, RESULT
      rt = _.reduce _.map(arr, handler), (a, b) ->
        return a or b
      if rt is RESULT.PASS
        continue
      else
        return rt
