V    = require('../src/validator')
validator = require('validator')
{ isString, isArray, isObject, isUndefined, isFunction } = _ = require('lodash')

Validator = {}

Validator.String = (str) ->
  return null unless str?
  return false unless _.isString(str)
  str.trim()

Validator.Array = (arr) ->
  return null unless arr
  return false unless _.isArray(arr)
  return arr

Validator.StringLike = (str) ->
  return Validator.String(str) or Validator.Number(str)

Validator.ObjectID = Validator.ObjectId = (oid) ->
  return null unless oid
  oid = Validator.String("#{oid}")
  return false unless oid
  if /^[0-9a-fA-F]{24}$/.test(oid)
    return oid
  else
    return false

Validator.NumberLike = (val) ->
  return null unless val?
  if validator.isNumeric(+val)
    return +val
  else
    return false

Validator.Number = (val) ->
  return null unless val?
  if validator.isNumeric(val)
    return val
  else
    return false

Validator.Money = (val) ->
  return null unless val?
  if /^\d+\.?\d{0,2}$/.test(val)
    return val
  else
    return false

Validator.URL = Validator.Url = (val) ->
  return null unless val
  if validator.isURL(val)
    return val
  else
    return false

Validator.Method = (val) ->
  return null unless val
  if val.toLowerCase() in ['get', 'put', 'post', 'del', 'delete']
    return val
  else
    return false

Validator.Boolean = (val) ->
  return null unless val?
  if val in ['true', true, 1, '1']
    return true
  else if val in ['false', false, 0, '0']
    return true
  else null

Validator.Date = (val) ->
  return null unless val
  date = new Date(val)
  if !!date.getTime()
    return date
  else
    return false

Validator.Email = (email) ->
  return null unless email
  email = Validator.String(email)
  return false unless email
  email = email.toLowerCase()
  if validator.isEmail(email)
    return email
  return false

V.includeType Validator

V.extendOperation

  $hasKeys: (target, keys) ->
    return null unless target
    return null unless keys and keys.length
    res = true
    for key in keys
      if _.isUndefined(target[key])
        res = false
        break
    return res and target

  $object: (target, [keyType, valType]) ->
    return null unless target
    res = true
    for key, val of target
      unless V.type(keyType, key) and V.type(valType, val)
        res = false
        break
    return res and target

  $commaArray: (target, type) ->
    return null unless target and _.isString(target) and type
    arr = target.split(',')
    res = true
    for item in arr
      unless V.type(type, item)
        res = false
        break
    return res and arr

  $range: (target, range) ->
    return null unless target
    num = null
    if isNumber(target)
      num = target
    else if not isUndefined(target.length)
      num = target.length
    if num is null
      return null
    return num < range[1] and num > range[0]