require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.updateDomByApiRequest', function() {
  var targetId = "update-dom-by-api-request-target-element";
  var insertId = "update-dom-by-api-request-insert-element";
  var get;

  before(function() {
    get = $.get;
    $(document.body).append("<p id=\"" + targetId + "\"></p>");
    $.get = function(urlNotNeeded, response) {
      response("<span id=\"" + insertId + "\">Luke</span>");
    }
  });

  afterEach(function() {
    $(document.body).find("#" + insertId).remove();
  });

  after(function() {
    $(document.body).find("#" + targetId).remove();
    $.get = get;
  });

  it('should place new element inside (append to) target node', function() {
    var $targetNode = $(document.body).find("#" + targetId);

    // First check inserted node is not there.
    expect($(document.body).find("#" + insertId).length > 0).is.false;

    utilities.updateDomByApiRequest("", {
      target: $targetNode,
      done: function() {
        var $insertedNode = $targetNode.find("#" + insertId);
        expect($targetNode).to.exist;
        expect($targetNode.length).to.equal(1);
        expect($insertedNode).to.exist;
        expect($insertedNode.length).to.equal(1);
        expect($targetNode.find($insertedNode).length > 0).to.be.true;
      }
    });
  });

  it('should place new element after target node', function() {
    var $targetNode = $(document.body).find("#" + targetId);

    // First check inserted node is not there.
    expect($(document.body).find("#" + insertId).length > 0).to.be.false;

    utilities.updateDomByApiRequest("", {
      type: "after",
      target: $targetNode,
      done: function() {
        var $insertedNode = $(document.body).find("#" + insertId);
        expect($targetNode).to.exist;
        expect($targetNode.length).to.equal(1);
        expect($insertedNode).to.exist;
        expect($insertedNode.length).to.equal(1);
        expect($targetNode.next().is($insertedNode)).to.be.true;
      }
    });
  });

  it('should append new element before target node', function() {
    var $targetNode = $(document.body).find("#" + targetId);

    // First check inserted node is not there.
    expect($(document.body).find("#" + insertId).length > 0).to.be.false;

    utilities.updateDomByApiRequest("", {
      type: "before",
      target: $targetNode,
      done: function() {
        var $insertedNode = $(document.body).find("#" + insertId);
        expect($targetNode).to.exist;
        expect($targetNode.length).to.equal(1);
        expect($insertedNode).to.exist;
        expect($insertedNode.length).to.equal(1);
        expect($targetNode.prev().is($insertedNode)).to.be.true;
      }
    });
  });

});
