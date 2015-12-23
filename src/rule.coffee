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
    else if _.isObject(rule)
      @_type = "operation"
    else if _.isFunction(rule)
      @_type = "function"
    else
      throw new Error("unrecognized rule")
    @_path = path
    @_rule = rule
    @_addition = addition or {}
    @

  check: (target) ->
    { _type, _addition, _rule } = @
    tar = u.resolvePath(@_path, target)
    res = Extends.addition.check(tar, _addition)
    if res is VALID
      return true
    if res is UNVALID
      return false
    if _type is 'function'
      return _rule(tar)
    return Extends[_type].check(tar, _rule)

module.exports = Rule
