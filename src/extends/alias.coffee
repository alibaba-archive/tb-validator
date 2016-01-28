_ = require('lodash')
Base = require('./extend')
util = require('../util')

# 空字符串 空对象 空数组则返true
isEmpty = (obj) ->
  if _.isArray(obj) and obj.length is 0
    return true
  if _.isPlainObject(obj)
    return true
  if obj is ''
    return true
  return false

ALIAS =

  $required: $neq: undefined

  $empty: isEmpty

  $null: $in: [null, 'null']

module.exports = new Base
  Data: ALIAS
  get: (key) ->
    return ALIAS[util.toStartWithDollar(key)]
