_ = require('lodash')
u = require('./util')
Extends = require('./extends')
Tree = require('./tree')
Rule = require('./rule')

afterLogic = (path) ->
  return false if path.length is 0
  Extends.logic.has _.last(path)

class RuleSet

  constructor: (obj) ->
    @uid = _.uniqueId('RuleSet_')
    @_treeHdl = new Tree
    @_rules = []
    @_ruleMap = {}
    @parse(obj)
    @

  uniqRule: ->
    _.uniqueId(@uid + '_')

  add: (rule) ->
    {path, check, logicChain, alias} = rule
    ruleHdl = new Rule(check, path)
    ruleHdl.uid = @uniqRule()
    @_rules.push ruleHdl
    aliases = Object.keys(alias)
    if aliases.length
      logicChain.push('$or')
      aliases.forEach (addi) =>
        _check = Extends.alias.get(addi)
        if _check
          _rule = new Rule(_check, path, true)
          _rule.uid = @uniqRule()
          @_rules.push _rule
          @_ruleMap[_rule.uid] = _rule
          @_treeHdl.initByChain(logicChain, _rule.uid)
    @_ruleMap[ruleHdl.uid] = ruleHdl
    @_treeHdl.initByChain(logicChain, ruleHdl.uid)
    @

  check: (obj) ->
    rules = @_rules
    valObj = {}
    rules.forEach (rule) ->
      rt = rule.check(obj)
      valObj[rule.uid] = rt
    console.log(valObj)
    res = !!@_treeHdl.resolve(valObj)
    uids
    unless res
      uids = @_treeHdl.findErrorLeafs()
    errs = _.map uids, (uid) =>
      return @_ruleMap[uid].toJSON()
    return [res, errs]

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
      if _.isArray data
        data.forEach (item, ind) ->
          _parse item, path.concat(unless afterLogic(path) then [andKey, ind] else ind)
      else if _.isFunction data
        _toRule(data, path, _.last(path))
      else if _.isPlainObject data
        keys = Object.keys(data)
        keys.forEach (key) ->
          if Extends.operation.has key
            _toRule(data, path, key)
          else if Extends.alias.has key
            _parse data[key], path.concat(key)
          else if Extends.logic.has key
            _parse data[key], path.concat(getKey(key))
          else
            path.push(andKey) unless afterLogic(path)
            _parse data[key], path.concat(key)
      else if _.isString data
        _toRule(data, path, _.last(path))
      else
        console.warn 'err', path

    # 将_parse过的data(形如'String:required'的字符串或key在OPS中,如$in)转化为标准的rule
    _toRule = (data, path, key) ->
      rule = {}
      if Extends.operation.has key
        rule.path = path
        rule.check = data
      else if _.isString data
        rule.path = path
        ps = data.split(':')
        type = ps[0]
        aliases = ps[1..]
        rule.check = type
        rule.alias = {}
        aliases.forEach (alias) ->
          rule.alias["$#{alias}"] = true
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
        if Extends.alias.has p
          return rule.alias[p] = true
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