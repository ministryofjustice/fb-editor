require("../../setup");

describe("EditableElement", function () {
  const helpers = require("./helpers");
  const c = helpers.constants;
  const COMPONENT_ID = "editable-element-methods-testsvdb";

  describe("Methods", function () {
    var created;

    beforeEach(function () {
      created = helpers.createEditableElement(COMPONENT_ID);
    });

    afterEach(function () {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    describe("edit()", function () {
      it("should add the editing class", function () {
        var $element = $(`#${COMPONENT_ID} > span`);
        expect($element.hasClass(c.EDIT_CLASSNAME)).to.be.false;

        created.instance.edit();

        $element = $(`#${COMPONENT_ID} > span`);
        expect($element.hasClass(c.EDIT_CLASSNAME)).to.be.true;
      });
    });

    describe("update()", function () {
      it("should update the content", function () {
        var $element = $(`#${COMPONENT_ID} > span`);
        expect(created.instance.content).to.equal(c.EDITABLE_TRIMMED_CONTENT);

        $element.text("  My updated content  ");
        created.instance.update();

        expect(created.instance.content).to.equal("My updated content");
      });

      it("should remove the editing class", function () {
        created.instance.edit();

        var $element = $(`#${COMPONENT_ID} > span`);
        expect($element.hasClass(c.EDIT_CLASSNAME)).to.be.true;

        created.instance.update();
        expect($element.hasClass(c.EDIT_CLASSNAME)).to.be.false;
      });
    });

    describe("populate()", function () {
      it("updates the content of the element", function () {
        var $element = $(`#${COMPONENT_ID} > span`);
        expect($element.text()).to.equal(c.EDITABLE_RAW_CONTENT);

        created.instance.populate("new content");

        $element = $(`#${COMPONENT_ID} > span`);
        expect($element.text()).to.equal("new content");
      });

      describe("without default content", function () {
        it("updates with original content if content is empty", function () {
          var $element = $(`#${COMPONENT_ID} > span`);
          expect($element.text()).to.equal(c.EDITABLE_RAW_CONTENT);

          created.instance.populate("");

          $element = $(`#${COMPONENT_ID} > span`);
          expect($element.text()).to.equal(c.EDITABLE_TRIMMED_CONTENT);
        });
      });

      describe("with default content", function () {
        beforeEach(function () {
          created = helpers.createEditableElement(COMPONENT_ID, {
            attributeDefaultText: "defaultText",
          });
        });

        it("updates with original content if content is empty", function () {
          var $element = $(`#${COMPONENT_ID} > span`);
          expect($element.text()).to.equal(c.EDITABLE_RAW_CONTENT);

          created.instance.populate("");

          $element = $(`#${COMPONENT_ID} > span`);
          expect($element.text()).to.equal(c.EDITABLE_DEFAULT_CONTENT);
        });
      });
    });

    describe("focus()", function () {
      it("places focus on the $node", function () {
        created.instance.focus();
        expect(document.activeElement).to.eql(
          created.instance.$editable.get(0),
        );
      });
    });

    describe("content()", function () {
      it("updates the content variable", function () {
        created.instance.content = "Updated content";
        expect(created.instance.content).to.equal("Updated content");
      });

      it("updates the content in the node", function () {
        created.instance.content = "New content";
        $element = $(`#${COMPONENT_ID} > span`);
        expect($element.text()).to.equal("New content");
      });

      it("calls the populate() method", function () {
        var spy = sinon.spy(created.instance, "populate");
        created.instance.content = "my new content";
        expect(spy).to.have.been.calledWith("my new content");
      });

      it("calls the emitSaveRequired() method", function () {
        var spy = sinon.spy(created.instance, "emitSaveRequired");
        created.instance.content = "my new content";
        expect(spy).to.have.been.calledOnce;
      });

      it("triggers the saveRequired event", function () {
        var eventCount = 0;

        $(document).on("SaveRequired", function () {
          eventCount++;
        });
        created.instance.content = "More new content";
        expect(eventCount).to.equal(1);
      });

      it("doesn't trigger saveRequired when content is original", function () {
        //reset
        helpers.teardownView(COMPONENT_ID);
        created = undefined;
        //new instance with default text
        created = helpers.createEditableElement(
          COMPONENT_ID,
          {},
          c.EDITABLE_TRIMMED_CONTENT,
        );
        var eventCount = 0;

        $(document).on("SaveRequired", function () {
          eventCount++;
        });

        created.instance.content = c.EDITABLE_TRIMMED_CONTENT;
        expect(eventCount).to.equal(0);
      });

      it("doesn't trigger saveRequired when content is default", function () {
        //reset
        helpers.teardownView(COMPONENT_ID);
        created = undefined;
        //new instance with default text
        created = helpers.createEditableElement(
          COMPONENT_ID,
          {
            attributeDefaultText: c.EDITABLE_DEFAULT_CONTENT,
          },
          " ",
        );
        var eventCount = 0;

        $(document).on("SaveRequired", function () {
          eventCount++;
        });
        created.instance.content = "";
        expect(eventCount).to.equal(0);
      });
    });
  });
});
