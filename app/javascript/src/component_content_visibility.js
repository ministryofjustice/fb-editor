
const utilities = require('./utilities');
const EVENT_QUESTION_CHANGE = "ContentVisibilityQuestion_Change";

class ContentVisibility {
  #config;
  #conditions; // Stores created BranchConditions
  #conditionCount; // TODO: Maybe remove if we can find way to use the #conditions.length
  #index; // Index number of the Branch

  constructor($node, config) {
    var content_visibility = this;
    var conf = utilities.mergeObjects({ content_visibility: this }, config);
    var $injector = $(conf.selector_condition_add, $node);
    // var $remover = $(conf.selector_branch_remove, $node);

    if($node.attr("id") == "" || $node.attr("id") == undefined) {
      $node.attr("id", utilities.uniqueString("conditional_content_"));
    }

    $node.addClass("ContentVisibility");
    $node.data("instance", this);

    this.#config = conf;
    this.#conditions = [];
    this.#conditionCount = 0;
    this.#index = Number(conf.index);
    this.$node = $node;
    this.view = conf.view;
    // this.destination = new BranchDestination($node.find(config.selector_destination), conf);
    this.conditionInjector = new ContentVisibilityConditionInjector($injector, conf);
    // this.remover = new ContentVisibilityRemover($remover, conf);

    this.$node.find(this.#config.selector_condition).each(function(index) {
      var $node = $(this);
      content_visibility.#conditionCount = index;
      content_visibility.#createCondition($node);
    });

    $(document).trigger('ContentVisibilityCreate', this);
  }

  get index() {
    return this.#index;
  }

  get conditions() {
    return this.#conditions;
  }

  addCondition() {
    var index = this.#conditionCount + 1;
    var $node = $(utilities.stringInject(this.#config.template_condition, {
      content_visibility_index: this.#index,
      condition_index: index
    }));

    this.#conditionCount = index;
    this.#createCondition($node);
    this.conditionInjector.$node.before($node);
  }

  removeCondition(condition) {
    // Find and remove from conditions array
    for(var i=0; i<this.#conditions.length; ++i) {
      if(this.#conditions[i] == condition) {
        this.#conditions.splice(i, 1);
      }
    }

    this.#updateConditions();
  }

  // destroy() {
  //   // 1. Anything specifig to this function here.
  //   this.$node.remove();

  //   // 2. Then trigger the related event for listeners.
  //   $(document).trigger('Branch_Destroy', this);
  // }

  #createCondition($node) {
    var condition = new ContentVisibilityCondition($node, utilities.mergeObjects(this.#config, {
      index: this.#conditionCount
    }));

    this.#conditions.push(condition);
    this.#updateConditions();
  }

  #updateConditions() {
    // Set whether it is the only one, or not.
    if(this.#conditions.length < 2) {
      this.$node.addClass("singleContentVisibilityCondition");
    }
    else {
      this.$node.removeClass("singleContentVisibilityCondition");
    }

    this.$node.trigger("ContentVisibility_UpdateConditions");
  }
}

class ContentVisibilityCondition {
  #config;
  #index;

  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);
    var $remover = $(conf.selector_condition_remove, $node);

    if($node.attr("id") == "" || $node.attr("id") == undefined) {
      $node.attr("id", utilities.uniqueString("content-visibility-condition_"));
    }

    $node.addClass("ContentVisibilityCondition");
    $node.data("instance", this);
    $node.append($remover);

    this.#config = conf;
    this.#index = conf.index;
    this.$node = $node;
    this.content_visibility = conf.content_visibility;
    this.question = new ContentVisibilityQuestion($node.find(conf.selector_question), conf);
    // this.remover = new BranchConditionRemover($remover, conf);
    this.answer = new ContentVisibilityAnswer($node.find(conf.selector_answer), conf);
  }

  update(component, callback) {
    var url;
    if(component) {
      url = utilities.stringInject(this.#config.answer_url, {
        component_id: component,
        content_visibility_index: this.content_visibility.index,
        condition_index: this.#index
      });

      utilities.updateDomByApiRequest(url, {
        target: this.$node,
        done: ($node) => {
          this.answer = new ContentVisibilityAnswer($node, this.#config);
          utilities.safelyActivateFunction(callback);
        }
      });
    }
  }

  clear() {
    // Clear any existing
    if(this.answer) {
      this.answer.$node.remove();
      this.answer = null;
    }
  }

  // destroy() {
  //   this.branch.removeCondition(this);
  //   this.$node.remove();
  // }
}

class ContentVisibilityConditionInjector {
  #config;

  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);

    $node.addClass("ContentVisibilityConditionInjector");
    $node.data("instance", this);
    $node.on("click", (e) => {
      e.preventDefault();
      conf.branch.addCondition();
    });

    this.#config = conf;
    this.content_visibility = conf.content_visibility;
    this.$node = $node;
  }
}

class ContentVisibilityQuestion {
  #config;
  #index;

  constructor($node, config) {
    var conf = utilities.mergeObjects({
      css_classes_error: ""
    }, config);

    $node.addClass("ContentVisibilityQuestion");
    $node.data("instance", this);
    $node.find("select").on("change.contentvisibilityquestion", (e) => {
      var select = e.currentTarget;
      var supported = $(select.selectedOptions).data("supports-branching");
      this.disable();
      this.change(supported, select.value);
    });

    this.#config = conf;
    this.condition = conf.condition;
    this.$node = $node;
  }

  set label(label) {
    this.$node.find("label").text(label);
  }

  disable() {
    this.$node.find('select').prop('disabled', true);
  }

  enable() {
    this.$node.find('select').prop('disabled', false);
  }

  change(supported, value) {
    var content_visibility = this.condition.content_visibility;
    this.clearErrorState();
    this.condition.clear();
    switch(supported) {
      case true:
           this.condition.update(value, () =>  {
             $(document).trigger(EVENT_QUESTION_CHANGE, content_visibility);
             this.enable();
           });
           break;
      case false:
           this.error("unsupported");
           this.enable();
           break;
      default:
           // Just trigger an event
           $(document).trigger(EVENT_QUESTION_CHANGE, content_visibility);
           this.enable();
    }
  }

  clearErrorState() {
    var classes = this.#config.css_classes_error.split(" ");

    this.condition.$node.removeClass("error");
    this.condition.$node.removeClass(this.#config.css_classes_error);

    if(this._$error && this._$error.length > 0) {
      this._$error.remove();
      this._$error = null;
    }

    this.condition.$node.find(this.#config.selector_error_messsage).remove();

    // Lastly remove any template injected error message classes identified by config.
    for(var i=0; i < classes.length; ++i) {
      if(classes[i].length > 0) {
        this.$node.removeClass(classes[i]);
        this.$node.find("." + classes[i]).removeClass(classes[i]);
      }
    }
  }

  error(type) {
    var $error = $("<p class=\"error-message\"></p>");
    var errors = this.#config.view.text.errors.conditional_visibility;
    switch(type) {
      case "unsupported": $error.text(errors.unsupported_question);
        break;
      default: $error.text("An error occured");
    }

    this._$error = $error;
    this.$node.append($error);
    this.condition.$node.addClass("error");
  }
}

class ContentVisibilityAnswer {
  #config;

  constructor($node, config) {
    var conf = utilities.mergeObjects({}, config);

    $node.addClass("ContentVisibilityAnswer");
    $node.data("instance", this);
    this.#config = conf;
    this.$node = $node;

    this.showHideAnswers();

    this.$node.find('[data-expression-operator]').on('change', (event) =>  {
      this.showHideAnswers();
    });
  }

  showHideAnswers() {
    var $condition = this.$node.find('[data-expression-operator]');
    var $answer = this.$node.find('[data-expression-answer]');
    var hideAnswers = $condition.find(':selected').data('hide-answers');

    if(hideAnswers) {
      $answer.hide();
      $answer.val([]);
    } else {
      $answer.show();
      if( !$answer.val() ) {
        $answer.val( $answer.find('option:first').val() );
      }
    }
  }
}

// class ContentVisibilityRemover {
//   #config;
//   #disabled = false;

//   constructor($node, config) {
//     var remover = this;
//     var conf = utilities.mergeObjects({}, config);

//     $node.addClass("ContentVisibilityRemover");
//     $node.data("instance", this);
//     $node.attr("aria-controls", conf.branch.$node.attr("id"));
//     $node.on("click", (e) => {
//       e.preventDefault();
//       remover.activate();
//     });

//     this.#config = conf;
//     this.branch = conf.branch;
//     this.$node = $node;
//   }

//   disable() {
//     this.$node.addClass("disabled");
//     this.#disabled = true;
//   }

//   enable() {
//     this.$node.removeClass("disabled");
//     this.#disabled = false;
//   }

//   isDisabled() {
//     return this.#disabled;
//   }

//   #action() {
//     // 1. Trigger the related event for listeners.
//     $(document).trigger("ContentVisibilityRemover_Action", this);
//     // 2. Finally pass off to the branch.
//     this.branch.destroy();
//   }

//   #confirm() {
//     var remover = this;
//     this.#config.confirmation_remove = false;
//     $(document).trigger("ContentVisibilityRemover_Confirm", {
//       instance: remover,
//       action:  function () { remover.activate(); },

//     });
//   }

//   // Check if confirmation is required or just run the action
//   activate() {
//     if(this.#config.confirmation_remove) {
//       this.#confirm();
//     }
//     else {
//       this.#action();
//     }
//   }
// }

module.exports = ContentVisibility;
