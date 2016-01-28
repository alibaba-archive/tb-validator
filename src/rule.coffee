_ = require('lodash')
u = require('./util')
Extends = require('./extends')
{ VALID, UNVALID, PASS } = r = require('./result')

class Rule

  constructor: (rule, addition, path) ->
    if addition
      Object.keys(addition).forEach (addi) ->
        unless Extends.addition.has(addi)
          throw Error("unrecognized addition: #{addi}")
    if _.isString(rule)
      @_type = "type"
      unless Extends.type.has(rule)
        throw new Error("unrecognized type: #{rule}")
    else if _.isFunction(rule)
      @_type = "function"
    else if _.isPlainObject(rule)
      @_type = "operation"
    else
      throw new Error("unrecognized rule")
    @_path = path
    @_isMulti = ~path.indexOf('$array')
    @_rule = rule
    @_addition = addition or {}
    @

  check: (target) ->
    { _type, _addition, _rule } = @
    @_target = target
    tar = u.resolvePath(@_path, target)
    unless @_isMulti
      tar = [tar]
    if _type is 'type'
      res = Extends.addition.check(tar, _addition)
      if res is VALID
        return true
      if res is UNVALID
        @_errType = 'addition'
        return false
    if _type is 'function'
      return _.reduce _.map(tar, _rule), (a, b) -> return a and b
    return Extends[_type].check(tar, _rule)

  toJSON: ->
    data =
      err: @_errType or @_type
      addition: @_addition
      rule: @_rule
      path: @_path
    return data

module.exports = Rule
