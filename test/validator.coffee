V = require('../src/validator')
_ = require('lodash')
require('./extend')

V.config
  format: true

{ isObject, isArray } = _
jsonStringify = (data, space) ->
  seen = []
  return JSON.stringify data, (key, val) ->
    if not val or typeof val isnt 'object'
      return val
    if seen.indexOf(val) isnt -1
      return '[Circular]'
    seen.push(val)
    return val
  , space

ruleForTest =
  $or:
    type:
      $in: ['a','b','c']
    $and:
      type: 'Number'
      diliver: 'Number'
  route: ['Method', 'Url']
  attachments:
    $array:
      _id: 'ObjectId'
      downloadUrl: 'Url'
      name: 'String'
      keys: $array: 'Number'
  '$or1':
    _id: 'ObjectId'
    name: 'String:empty'
    url: [
      'Method'
      'URL'
    ]
  '$or2':
    _type:
      '$in': ['delay', 'gowell']
    show: '$eq': 'yes'
    like:
      $array:
        name: 'String'
        count: 'Number'
        link:
          $array:
            id: 'ObjectID'
            state: 'Number'
    link:
      '_id': 'ObjectID'
      'secret': 'String'
  '$required':
    state: 'String'
    showname: '$in': ['are', 'you', 'ok']
    kom:
      '_id': 'ObjectID'
      'secret': 'String'

toCheck =
  type: 1
  diliver: 2
  route: ['get', 'http://www.baidu.com']
  attachments: [
    {
      _id: '51762b8f78cfa9f357000011'
      downloadUrl: 'http://www.baidu.com/q.png'
      name: 'my'
      keys: [1, 2]
    }
  ]
  _id: "51762b8f78cfa9f357000011"
  name: '12'
  url: ['get', 'www.baidu.com']
  _type: 'delay'
  show: 'yes'
  like: [
    name: 'asdzxc'
    count: 12
    link: [
      id: '51762b8f78cfa9f357000011'
      state: 43
    ,
      id: '51762b8f78cfa9f357000012'
      state: 44
    ]
  ,
    name: 'asdzxc'
    count: 12
    link: [
      id: '51762b8f78cfa9f357000011'
      state: 43
    ,
      id: '51762b8f78cfa9f357000012'
      state: 44
    ]
  ,
    name: 'asdzxc'
    count: 12
    link: [
      id: '51762b8f78cfa9f357000011'
      state: 43
    ,
      id: '51762b8f78cfa9f357000011'
      state: 44
    ]
  ]

  link:
    _id: '51762b8f78cfa9f357000011'
    secret: 'adefrfsae'
  state: 'djnkjdnakjd'
  showname: 'are'
  kom:
    _id: '51762b8f78cfa9f357000011'
    secret: 'adefrfsae'

rules = V.parse(ruleForTest)
res = V.checkAll(toCheck, rules)
# a = new Date
# c = 2000
# while c--
#   res = V.checkAll(toCheck, rules)
# b = new Date
# console.log b-a
console.log jsonStringify(res, 2)
console.log toCheck

console.log V.$in(1, [1,2])

console.log V.$required(undefined, 1)

console.log V.type('String', 'asdas')
