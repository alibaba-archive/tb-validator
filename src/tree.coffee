logic = require('./extends/logic')
_ = require('lodash')

class LeafNode
  constructor: (name) ->
    @name = name
    @_val = null
    @

  resolve: ->
    return @val()

  val: (value) ->
    if arguments.length
      @_val = value
    else
      return @_val

class TreeNode
  constructor: (name, val) ->
    @name = name
    if name is 'root'
      key = '$and'
    else
      key = logic.getKeyFromStr(name)
    op = logic.get(key)
    throw new Error("unvalid operation: #{key}") unless op
    @_op = op
    @_val = val = val or []
    @_map = {}
    val.forEach (v) =>
      @_map[v.name] = v
    @

  resolve: ->
    _val = @_val
    return @_op.apply(null, _.map(_val, (val) ->
      return val.resolve()
    ))

  addChildNode: (child) ->
    _val = @_val
    _val.push child
    @_map[child.name] = child

  getChild: (name) ->
    return @_map[name]

class LogicTree
  constructor: ->
    @_root = new TreeNode('root')
    @_leafMap = {}

  initByChain: (chain, leafName) ->
    node = @_root
    for name in chain
      _node = node.getChild name
      if _node
        node = _node
      else
        _node = new TreeNode(name)
        node.addChildNode(_node)
        node = _node
    leaf = new LeafNode(leafName)
    @_leafMap[leaf.name] = leaf
    node.addChildNode(leaf)

  resolve: (valObj) ->
    console.log valObj
    for key, val of valObj
      leaf = @_leafMap[key]
      leaf.val(val) if leaf
    @_root.resolve()

module.exports = LogicTree