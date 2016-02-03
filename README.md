# evocatio

[![NPM Version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]

```javascript
fns = require("evocatio")();

fns.register("whoami", => "nobody");

fns.register("namespace.async", {
    operation: function*(arg, more){
        yield asyncoperation(arg);
    }
});

fns.dispatch("whoami", {});  // "nobody"
fns.dispatch("namespace.async.operation", {arg: null, more: false});  // promise
```

[npm-image]: https://img.shields.io/npm/v/evocatio.svg?style=flat
[npm-url]: https://npmjs.org/package/evocatio
[travis-image]: https://img.shields.io/travis/zweifisch/evocatio.svg?style=flat
[travis-url]: https://travis-ci.org/zweifisch/evocatio
