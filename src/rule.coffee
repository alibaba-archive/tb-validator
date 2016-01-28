_ = require('lodash')
u = require('./util')
Extends = require('./extends')
{ VALID, UNVALID, PASS } = r = require('./result')

class Rule

  constructor: (rule, path, alias) ->
    if _.isString(rule)
      @_type = "type"
    else if _.isFunction(rule)
      @_type = "function"
    else if _.isPlainObject(rule)
      @_type = "operation"
    else
      throw new Error("unrecognized rule")
    @_path = path
    @_isMulti = ~path.indexOf('$array')
    @_rule = rule
    @_alias = alias
    @

  check: (target) ->
    { _type, _rule } = @
    @_target = target
    tar = u.resolvePath(@_path, target)
    unless @_isMulti
      tar = [tar]
    if _type is 'function'
      return _.reduce _.map(tar, _rule), (a, b) -> return a and b
    return Extends[_type].check(tar, _rule)

  toJSON: ->
    data =
      err: @_errType or @_type
      rule: @_alias or @_rule
      path: @_path
    return data

module.exports = Rule
