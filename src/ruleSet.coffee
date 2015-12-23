_ = require('lodash')
u = require('./util')
Extends = require('./extends')
Tree = require('./tree')
Rule = require('./rule')

afterLogic = (path) ->
  Extends.logic.has _.last(path)

class RuleSet

  constructor: (obj) ->
    @uid = _.uniqueId('RuleSet_')
    @_treeHdl = new Tree
    @_rules = []
    @parse(obj)
    @

  uniqRule: ->
    _.uniqueId(@uid + '_')

  add: (rule) ->
    {path, check, logicChain, addition} = rule
    ruleHdl = new Rule(check, addition, path)
    ruleHdl.uid = @uniqRule()
    @_rules.push ruleHdl
    @_treeHdl.initByChain(logicChain, ruleHdl.uid)
    @

  check: (obj) ->
    rules = @_rules
    valObj = {}
    rules.forEach (rule) ->
      rt = rule.check(obj)
      valObj[rule.uid] = rt
    return @_treeHdl.resolve(valObj)

  parse: (obj) ->
    return null unless obj

    depth = 0
    getKey = (sysKey) ->
      return "#{sysKey}#{depth}"

    ruleSet = @
    # 递归地解析传入的规则对象
    _parse = (data, path) ->
      depth++
      andKey = getKey('$and')
      if _.isObject data
        keys = Object.keys(data)
        keys.forEach (key) ->
          if Extends.operation.has key
            _toRule(data, path, key)
          else if Extends.addition.has key
            _parse data[key], path.concat(key)
          else if Extends.logic.has key
            _parse data[key], path.concat(getKey(key))
          else
            path.push(andKey) unless afterLogic(path)
            _parse data[key], path.concat(key)
      else if _.isArray data
        data.forEach (item, ind) ->
          _parse item, path.concat(unless afterLogic(path) then [andKey, ind] else ind)
      else if _.isString data
        _toRule(data, path, _.last(path))
      else if _.isFunction data
        _toRule(data, path, _.last(path))
      else
        console.log 'err', path

    # 将_parse过的data(形如'String:required'的字符串或key在OPS中,如$in)转化为标准的rule
    _toRule = (data, path, key) ->
      rule = {}
      if Extends.operation.has key
        rule.path = path
        rule.check = data[key]
      else if _.isString data
        rule.path = path
        ps = data.split(':')
        type = ps[0]
        additions = ps[1..]
        rule.check = type
        rule.addition = {}
        additions.forEach (addition) ->
          rule.addition["$#{addition}"] = true
      else if _.isFunction data
        rule.path = path
        rule.check = data
      else
        return
      formated = _format(rule)
      ruleSet.add(formated) if formated

    # 格式化_toRule的结果，将path中的关键字(如$or,$and,$required等)分离出来
    _format = (rule) ->
      { path, check } = rule
      keys = []
      logics = []
      last = null
      path.forEach (p) ->
        if Extends.addition.has p
          return rule.addition[p] = true
        if Extends.logic.has p
          logics.push p
        else if p is '$array' and last is p
          return
        else
          last = p
          keys.push p
      # key = keys.pop()
      # if key is '$array'
      #   key = keys.pop()
      #   rule.isArray = true
      rule.path = keys.join('.')
      rule.logicChain = logics
      return rule

    _parse(obj, [])

module.exports = RuleSet