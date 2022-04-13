require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.stringInject', function() {
  it('should inject matching strings', function() {
    var text = "These are not the #{noun} you are #{verb} for.";
    var words = {
      noun: "droids",
      verb: "looking"
    }

    expect(utilities.stringInject(text, words)).to.equal("These are not the droids you are looking for.");
  });

  it('should not inject unmated strings', function() {
    var text = "These are not the #{noun} you are #{verb} for.";
    var words = {
      noun: "droids",
      adjective: "metallic"
    }

    expect(utilities.stringInject(text, words)).to.equal("These are not the droids you are #{verb} for.");
  });
});
