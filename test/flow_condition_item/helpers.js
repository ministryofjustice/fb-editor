const FlowConditionItem = require("../../app/javascript/src/component_flow_condition_item.js");
const GlobalHelpers = require("../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "FlowConditionItem",
  CLASSNAME_FAKE_FLOW_ITEM: "fake-flow-item",

  FLOW_CONDITION_ITEM_CONFIG: {
    next: "id-xyz",
    row: 2,
    column: 3,
    x_in: 100,
    x_out: 150,
    y: 20
  },

  NODE_FROM_NAME: "node-from-element",
  NODE_NEXT_NAME: "node-next-element",

  TEXT_HEADING: "This is a heading",
  TEXT_CONTENT: "This is some content"
}


/* Creates a new FlowConditionItem from only passing in an id.
 *
 * @id     (String) String used to assign unique ID value.
 *
 * Returns the following object:
 *
 * {
 *   $node: <jQuery wrapped HTML element used for FlowConditionItem target>
 *   config: <mix of default config items and ID passed in>
 *   item: <FlowConditionItem instance created>
 *  }
 *
 **/
function createFlowConditionItem(id) {
  var $container = $("#" + id);
  var $node = $container.find("li").eq(0);
  var config = GlobalHelpers.mergeConfig(constants.FLOW_CONDITION_ITEM_CONFIG, {
    $from: $container.find("[data-name=" + constants.NODE_FROM_NAME + "]", $node),
    $next: $container.find("[data-name=" + constants.NODE_NEXT_NAME + "]", $node)
  });

  return {
    $node: $node,
    config: config,
    item: new FlowConditionItem($node, config)
  }
}


/* Set up the DOM to include template code for flow conditions and anything else required.
 *
 * @id (String) Add an identifier to the container UL to allow more than one at once.
 *
 **/
function setupView(id) {
  var $html = $(
      `<div id="` + id + `">
         <div class="` + constants.CLASSNAME_FAKE_FLOW_ITEM + `" data-name="` + constants.NODE_FROM_NAME + `"></div>
         <div class="` + constants.CLASSNAME_FAKE_FLOW_ITEM + `" data-name="` + constants.NODE_NEXT_NAME + `"></div>
         <ul class="flow-conditions" id="` + id + `">
           <li class="flow-condition" data-from="` + constants.NODE_NEXT_NAME + `" data-next="` + constants.NODE_NEXT_NAME + `">
             <div class="flow-expressions">
               <span class="flow-expression" data-otherwise="false">
                 <span class="question">Checkbox1</span>
                 <span class="operator">contains</span>
                 <span class="answer">Option 1</span>
             </span>
           </div>
         </li>

         <li class="flow-condition" data-from="2a0d9133-c0f0-46bf-a1b1-fd1fa70bb58a-1" data-next="017097f7-be0d-42d3-b650-c46d789692ad">
           <div class="flow-expressions">
             <span class="flow-expression" data-otherwise="false">
               <span class="question">Checkbox1</span>
               <span class="operator">contains</span>
               <span class="answer">Option 2</span>
             </span>
           </div>
         </li>

         <li class="flow-condition" data-from="2a0d9133-c0f0-46bf-a1b1-fd1fa70bb58a-2" data-next="19783726-7c54-4a9a-a7f7-c81006569977">
           <div class="flow-expressions">
             <span class="flow-expression" data-otherwise="true">
               <span class="question">Otherwise</span>
             </span>
           </div>
         </li>
       </ul>
     </div>`);

  $(document.body).append($html);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#" + id).remove();
}



module.exports = {
  constants: constants,
  createFlowConditionItem: createFlowConditionItem,
  setupView: setupView,
  teardownView: teardownView
}


