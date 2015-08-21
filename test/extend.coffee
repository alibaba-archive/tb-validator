V = require('../src/validator')
validator = require('validator')
_ = require('lodash')

Validator = {}

Validator.RRule = (recurrence) ->
  return null unless recurrence
  Recurrence.checkRule(recurrence)

Validator.Phone = (str) ->
  str or= ''
  str = '+' + str
  phoneService(str).length > 0
  # /^\+?[0-9]{1}[0-9]{3,14}$/.test(str)

Validator.String = (str) ->
  return null unless str?
  return false unless _.isString(str)
  str.trim()

Validator.StringLike = (str) ->
  return Validator.String(str) or Validator.Number(str)

Validator.ObjectID = Validator.ObjectId = (oid) ->
  return null unless oid
  return false unless Validator.String("#{oid}")
  /^[0-9a-fA-F]{24}$/.test(oid)

Validator.Number = (val) ->
  return null unless val?
  validator.isNumeric(val)

Validator.Money = (val) ->
  return null unless val?
  /^\d+\.?\d{0,2}$/.test(val)

Validator.URL = Validator.Url = (val) ->
  return null unless val
  validator.isURL(val)

Validator.Method = (val) ->
  return null unless val
  return val.toLowerCase() in ['get', 'put', 'post', 'del', 'delete']

Validator.Array = (array, fieldType = 'string') ->
  return null unless array?
  return false unless array instanceof Array
  array = ( ele for ele in array when !!ele )
  !array.some (ele) ->
    if fieldType is 'string' and
    typeof ele is 'string'
      ele = Validator.String(ele)
      return true unless ele
    if fieldType is 'ObjectID'
      return !Validator.ObjectID(ele)
    typeof ele isnt fieldType

Validator.Boolean = (val) ->
  return null unless val?
  if val in ['true', true, 1, '1']
    return true
  else if val in ['false', false, 0, '0']
    return false
  else null

Validator.Date = (val) ->
  return null unless val
  date = new Date(val)
  !!date.getTime()


Validator.Email = (email) ->
  return null unless email
  email = Validator.String(email)
  return false unless email
  email = email.toLowerCase()
  if validator.isEmail(email)
    return email
  return false

Validator.length = (minlength = 10, maxlength = 50) ->
  charReg = /^(\w|\s|[・@_*]|[\u4E00-\u9FA5])*$/
  (val) ->
    val = Validator.String(val)
    return false unless val
    if minlength and val.length < minlength
      return false
    if val.length > maxlength
      return false
    return true

V.extendMethod Validator

