// Generated by CoffeeScript 1.9.1
(function() {
  var Extend, P, Parsers;

  Extend = require('./extend');

  Parsers = [];

  P = module.exports = {
    get: function() {
      return Parsers;
    },
    add: function(parser) {
      return Parsers.push(parser);
    }
  };

  P.add(function(str, ruleSet, ruleIns) {
    var handler, pres, ps, type;
    if (!/^\w+(\:\w+)+$/.test(str)) {
      return false;
    }
    ps = str.split(':');
    type = ps[0];
    pres = ps.slice(1).map(function(pre) {
      return '$' + pre;
    });
    handler = Extend.getByName('type');
    if (!handler.get(type)) {
      return false;
    }
    ruleIns.setHandler(handler, type);
    ruleIns.addAdditions(pres);
    ruleSet.add(ruleIns);
    return true;
  });

}).call(this);