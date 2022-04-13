require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.maxWidth', function() {
  it('should return the maxWidth found in a collection', function() {
    var $item1 = $("<p id=\"test-maxwidth-item1\">width item 1");
    var $item2 = $("<p id=\"test-maxwidth-item2\">width item 2");
    var $item3 = $("<p id=\"test-maxwidth-item3\">width item 3");
    var $collection = $(); // empty jQuery collection.

    // Add some widths...
    $item1.css({ width: "300px" });
    $item2.css({ width: "500px" });
    $item3.css({ width: "400px" });

    // Stick them in the document...
    $(document.body).append($item1);
    $(document.body).append($item2);
    $(document.body).append($item3);

    // Find the items...
    $collection = $(document.body).find("#test-maxwidth-item1, #test-maxwidth-item2, #test-maxwidth-item3");

    // Check we have them and their widths are correct...
    expect($collection.length).to.equal(3);
    expect($collection.eq(0).width()).to.equal(300);
    expect($collection.eq(1).width()).to.equal(500);
    expect($collection.eq(2).width()).to.equal(400);

    // Check we can find the max width
    expect(utilities.maxWidth($collection)).to.equal(500);
  });
});
