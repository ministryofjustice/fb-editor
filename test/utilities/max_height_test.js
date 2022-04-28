require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.maxHeight', function() {
  it('should return the maxHeight found in a collection', function() {
    var $item1 = $("<p id=\"test-maxheight-item1\">width item 1");
    var $item2 = $("<p id=\"test-maxheight-item2\">width item 2");
    var $item3 = $("<p id=\"test-maxheight-item3\">width item 3");
    var $collection = $(); // empty jQuery collection.

    // Add some heights...
    $item1.css({ height: "300px" });
    $item2.css({ height: "500px" });
    $item3.css({ height: "400px" });

    // Stick them in the document...
    $(document.body).append($item1);
    $(document.body).append($item2);
    $(document.body).append($item3);

    // Find the items...
    $collection = $(document.body).find("#test-maxheight-item1, #test-maxheight-item2, #test-maxheight-item3");

    // Check we have them and their heights are correct...
    expect($collection.length).to.equal(3);
    expect($collection.eq(0).height()).to.equal(300);
    expect($collection.eq(1).height()).to.equal(500);
    expect($collection.eq(2).height()).to.equal(400);

    // Check we can find the max width
    expect(utilities.maxHeight($collection)).to.equal(500);
  });
});
