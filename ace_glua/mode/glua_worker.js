define(function(require, exports, module) {
"use strict";

var oop = require("../lib/oop");
var Mirror = require("../worker/mirror").Mirror;

var Worker = exports.Worker = function(sender) {
    Mirror.call(this, sender);
    this.setTimeout(500);
};

oop.inherits(Worker, Mirror);

(function() {

    this.onUpdate = function() {
    };

}).call(Worker.prototype);

});
