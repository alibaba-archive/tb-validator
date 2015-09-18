v = require('../src/validator')
require('./extend')

rules = $or:
  displayFields: "Array:required"
  _approverIds:
    $array: "ObjectId:required"

data =
  _approverIds: ["cccccccccccccccccccccccc"]

console.log v.checkAll(data, v.parse(rules))