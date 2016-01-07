_         = require('lodash')
Extends = { addition, type, operation, system } = require('./extends')
Rule = require('./rule')
RuleSet = require('./ruleSet')

module.exports =
  Extends: Extends
  extendOperation: _.bind operation.extend, operation
  extendAddition: _.bind addition.extend, addition
  extendType: _.bind type.extend, type
  includeOperation: _.bind operation.include, operation
  includeAddition: _.bind addition.include, addition
  includeType: _.bind type.include, type
  check: (rule, obj) ->
    rset = new RuleSet(rule)
    console.log rset
    rset.check(obj)
  Rule: Rule
  RuleSet: RuleSet
