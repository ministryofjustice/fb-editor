const Expander = require("../../../app/javascript/src/component_expander.js");
const GlobalHelpers = require("../../helpers.js");


const constants = {
  CLASSNAME_ACTIVATOR: "Expander__activator",
  CLASSNAME_COMPONENT: "Expander",
  CLASSNAME_CONTENT: "content",
  CLASSNAME_CONTENT_CONTAINER: "content-container"
}


/* Creates a new Expander from only passing in an id and optional config.
 *
 * @id     (String) String used to assign unique ID value.
 * @config (Object) Optional config can be passed in to override the defaults.
 *
 * Returns the following object:
 *
 * {
 *   html: <html used to simulate content for creating expander>
 *   $node: <jQuery enhanced node (before expander instantiation) of the html>
 *   expander: <Expander instance created>
 *  }
 *
 **/
function createExpander(id, config) {
  var $node = $("#" + id + " ." + constants.CLASSNAME_CONTENT);

  // configurable component config
  //   - activator_source
  //   - wrap_content
  //   - auto_open
  //   - duration
  var conf = GlobalHelpers.mergeConfig({
               activator_source: $node.find('h2').first()
             }, config);

  return {
    html: $node.get(0).outerHTML,
    $node: $node,
    expander: new Expander($node, conf)
  }
}


/* Set up the DOM to include code for Expander content and anything else required.
 *
 * @id (String) Add an identifier to the container DIV to allow more than one at once.
 *
 **/
function setupView(id) {
  var html = `<div id="` + id + `">
                <div class="` + constants.CLASSNAME_CONTENT + `">
                  <h2>Title</h2>
                  <p>Lorem ipsum dolor sit amet</p>
                  <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
                  <p>Lorem ipsum dolor sit amet consecteteur</p>
                </div>
              </div>\n\n`;

  $(document.body).append(html);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#", id).remove();
}



module.exports = {
  constants: constants,
  createExpander: createExpander,
  setupView: setupView,
  teardownView: teardownView,
  findButtonByText: GlobalHelpers.findButtonByText
}
