validator = require('validator')
_         = require('lodash')

{ isString, isArray, isObject, isUndefined, isFunction } = _

OPS = '$in,$eq,$neq'.split(',')
SYS = '$or,$and'.split(',')
CUS = '$required,$empty'.split(',')

OPKEY = 'op'
CUKEY = 'cu'
MEKEY = 'me'

Extends = {}
OPTS =
  format: false

Extends[OPKEY] =

  $in: (item, arr) ->
    return item in arr

  $eq: _.isEqual

  $neq: ->
    return not _.isEqual.apply(_, arguments)

Extends[CUKEY] =

  $required: (target, required) ->
    if required and isUndefined target
      return false
    else
      return true

  $empty: (target, empty) ->
    if not empty and isEmpty target
      return false
    else
      return true

Extends[MEKEY] =

  $type: (target, type) ->
    getMethod(type)(target)

extend = (type) ->
  _extend = (handler, name) ->
    if type isnt MEKEY and not /^\$/.test(name)
      return false
    if Extends[type][name]
      console.warn "key #{name} is already existed"
    Extends[type][name] = handler
    if type is OPKEY
      OPS.push name
    else if type is CUKEY
      CUS.push name
    return name
  (name, handler) ->
    if isObject name
      _.mapKeys name, _extend
    else
      _extend(handler, name)

# 空字符串 空对象 空数组则返true
isEmpty = (obj) ->
  if isArray obj and obj.length is 0
    return true
  if isObject obj and _.keys(obj).length is 0
    return true
  if obj is ''
    return true
  return false

afterSYS = (path) ->
  isSysKey _.last(path)

isSysKey = (key) ->
  /^\$(and|or)/.test(key)

isCustomHandlerKey = (key) ->
  /^\$FN/.test(key)

formatSysKey = (key) ->
  if /^\$or/.test(key)
    return 'or'
  else
    return 'and'

getMethod = (name) ->
  extendFn = Extends[MEKEY][name]
  if extendFn
    return extendFn
  else
    return validator[name]

# 类似lodash _.result ，遇到$array则展开数组
result = (obj, path) ->
  return obj unless obj and path
  if ~path.indexOf('$array')
    pis = path.split(/^\$array\.|\.\$array\.|\.\$array$/)
    rt = obj
    curriedResult = _.curryRight(_.result)(undefined)
    max = pis.length - 1
    pis.forEach (p, ind) ->
      # 以$array结尾的情况
      if p is '' and ind is max
        rt = [].concat.apply [], rt
      else
        if isArray rt
          rt = _.map rt, (r) ->
            curriedResult(p)(r)
          # 如果不是最后一次，则展开结果数组
          if ind < max
            rt = [].concat.apply [], rt
        else if isObject rt
          rt = _.result rt, p
    return rt
  else
    return _.result obj, path

# 解析传入的规则
parse = (obj) ->
  if isObject obj
    data = obj
  else if isArray obj
    return obj.map (d) -> parse(d)
  else
    return null

  orCount = 1
  andCount = 1
  getKey = (type) ->
    if type is 'or'
      return "$or#{orCount++}"
    else
      return "$and#{andCount++}"

  rt = []
  # 递归地解析传入的规则对象
  _parse = (data, path) ->
    andKey = getKey('and')
    orKey = getKey('or')
    if isObject data
      keys = Object.keys(data)
      keys.forEach (key) ->
        if key in OPS
          _toRule(data, path, key)
        else if key in CUS
          _parse data[key], path.concat(key)
        else if isSysKey(key)
          _parse data[key], path.concat(if key is '$and' then andKey else getKey('or'))
        else
          path.push(andKey) unless afterSYS(path)
          _parse data[key], path.concat(key)
    else if isArray data
      data.forEach (item, ind) ->
        _parse item, path.concat(unless afterSYS(path) then [andKey, ind] else ind)
    else if isString data
      _toRule(data, path, _.last(path))
    else if isFunction data
      _toRule(data, path, _.last(path))
    else
      console.log 'err', path

  # 将_parse过的data(形如'String:required'的字符串或key在OPS中,如$in)转化为标准的rule
  _toRule = (data, path, key) ->
    rule = {}
    if key in OPS
      rule.path = path
      rule.check = [key, data[key]]
    else if isString data
      rule.path = path
      ps = data.split(':')
      type = ps[0]
      addtions = ps[1..]
      rule.check = ['$type', type]
      addtions.forEach (addtion) ->
        rule["$#{addtion}"] = true
    else if isFunction data
      rule.path = path
      rule.check = ["$FN:#{key}", data]
    else
      return
    rt.push rule

  # 格式化_toRule的结果，将path中的关键字(如$or,$and,$required等)分离出来
  _format = (rules) ->
    rt = []
    rules.forEach (rule) ->
      { path, check } = rule
      CUS.forEach (ckey) ->
        if ckey in path
          path = _.without path, ckey
          rule[ckey] = true
      keys = []
      sys = []
      path.forEach (p) ->
        (if isSysKey(p) then sys else keys).push p
      key = keys.pop()
      if key is '$array'
        key = keys.pop()
      rule.key = key
      rule.path = keys.join('.')
      rule.sys = sys
      rule.id = _.uniqueId('rule_')
      rt.push rule
    rt

  _parse(data, ['$and0'])
  rules = _format rt
  return rules

# 先检查类型,OPS,CUS规则,如果没有出错,再根据SYS规则归并结果集，返回[err, res]
checkAll = (obj, rules) ->
  rt = null
  queue = []
  maxLen = 0
  rulesById = {}
  errArr = null

  # 追踪错误信息
  errObj = {}
  trackErr = (op, res, items) ->
    val = if res then 0 else 1
    items.forEach ([sys, rt, id]) ->
      if _.isArray id
        ids = _.flatten(id, true)
        ids.forEach (id) -> errObj[id] = val
      else
        errObj[id] = val

  # 归并结果
  _resolve = (table, maxLen) ->
    if maxLen
      toResolve = {}
      rest = table.filter ([sys, res, id]) ->
        if sys.length is maxLen
          key = sys.join('.')
          sop = sys.pop()
          (toResolve[key] or= [sop]).push [sop, res, id]
          return false
        else
          return true
      _.mapKeys toResolve, (val, key) ->
        op = formatSysKey(val[0])
        items = val.slice(1)
        rts = _.pluck items, '1'
        ids = _.pluck items, '2'
        if op is 'or'
          symbol = '||'
        else
          symbol = '&&'
        rt = eval(rts.join(symbol))
        trackErr(op, rt, items)
        rest.push [ key.split('.')[0..-2], rt, ids ]
      maxLen--
      _resolve(rest, maxLen)
    else
      rt = eval((table.map (arr) -> arr[1]).join('&&'))
      trackErr('and', rt, table)
      return rt
  # 检查规则
  rules.forEach (rule) ->
    [err, res, target] = check(obj, rule)
    queue.push [rule.sys, res, rule.id]
    rulesById[rule.id] =
      path: rule.path
      err: err
      target: target
    len = rule.sys.length
    maxLen = len if len > maxLen
  rt = _resolve(queue, maxLen)
  # 收集错误信息
  _.mapKeys errObj, (value, key) ->
    if value and rulesById[key].err
      errArr or= []
      errArr.push rulesById[key]
  return [errArr, rt]

check = (obj, rule) ->
  { path, key, required, empty } = rule
  [ op, data ] = rule.check
  target = result obj, path
  rt = false
  err = null
  if isCustomHandlerKey(op)
    method = data
  else if op in OPS
    method = Extends[OPKEY][op]
  else
    method = getMethod(data)

  _wrap = (target, handler, addtion) ->
    single = false
    unless isArray target
      target = [target]
      single = true
    rts = _.map target, (tar) ->
      handler(tar, addtion)
    rt = _.reduce rts, (a, b) ->
      a && b
    return [rt, if single then rts[0] else rts]

  _check = (tar, key) ->
    toCheck = tar[key]
    for cusRule in CUS
      handler = Extends[CUKEY][cusRule]
      [rt] = _wrap toCheck, handler, rule[cusRule]
      unless rt
        err = cusRule
        return false
    if not method
      rt = false
      err = 'Operation'
    else
      [rt, rts] = _wrap toCheck, method, data
      if OPTS.format
        tar[key] = rts
      err = [op, data] unless rt
    return rt

  if isArray(target) and /\$array$/.test(path)
    for tar in target
      rt = _check(tar, key)
      break if err
    rt = true unless err
  else
    rt = _check(target, key)
  [err, !!rt, target[key]]

module.exports =
  extendOperation: extend(OPKEY)
  extendAddtion: extend(CUKEY)
  extendMethod: extend(MEKEY)
  checkAll: checkAll
  parse: parse
  config: (opts) ->
    OPTS = _.assign OPTS, opts
