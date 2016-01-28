_         = require('lodash')
Extends = { alias, type, operation, system } = require('./extends')
Rule = require('./rule')
RuleSet = require('./ruleSet')

module.exports =
  Extends: Extends
  extendOperation: _.bind operation.extend, operation
  extendAlias: _.bind alias.extend, alias
  extendType: _.bind type.extend, type
  includeOperation: _.bind operation.include, operation
  includeAlias: _.bind alias.include, alias
  includeType: _.bind type.include, type
  check: (rule, obj) ->
    rset = new RuleSet(rule)
    console.log rset._ruleMap
    rset.check(obj)
  Rule: Rule
  RuleSet: RuleSet
