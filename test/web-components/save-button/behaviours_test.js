require("../../setup");
const {
  createComponent,
  createTemplate,
  getElements,
  cleanBody,
} = require("./helpers");

const {
  SaveButton,
} = require("../../../app/javascript/src/web-components/save-button");
const ID = "save-button-component-behaviours-form";

describe("save-button", function () {
  const sandbox = sinon.createSandbox();
  let form, saveButton, input, description;

  before(function () {
    if (!window.customElements.get("save-button")) {
      window.customElements.define("save-button", SaveButton, {
        extends: "button",
      });
    }
  });

  afterEach(function () {
    sandbox.restore();
    saveButton = form = input = description = undefined;
    cleanBody();
  });

  describe("Behaviours", function () {
    describe("core", function () {
      beforeEach(async function () {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`);
        await createComponent(form);
        ({ saveButton, form, input, description } = getElements());
      });

      it("should create an instance of SaveButton", function () {
        expect(saveButton).to.exist;
        expect(saveButton).to.be.instanceOf(SaveButton);
      });

      it("should not create an assistive description", function () {
        expect(description).to.not.exist;
      });
    });

    describe("with assistive text", function () {
      beforeEach(async function () {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`);
        await createComponent(form, {
          "data-assistive-text": "assistive text",
        });
        ({ saveButton, form, input, description } = getElements());
      });

      it("should create an assistive description element", function () {
        expect(description).to.exist;
        expect(description).to.have.class("sr-only");
        expect(description).to.have.attribute("id", `${ID}-save-description`);

        expect(saveButton).to.have.attribute(
          "aria-describedby",
          `${ID}-save-description`,
        );
      });
    });

    describe("no save required", function () {
      beforeEach(async function () {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`);
        await createComponent(form, {
          "data-assistive-text": "assistive text",
          "data-saved-label": "all good",
          "data-unsaved-label": "click me",
          "data-saving-label": "working on it",
        });
        ({ saveButton, form, input, description } = getElements());
      });

      it("should have the saved label", function () {
        expect(saveButton.innerText).to.eq("all good");
      });

      it("should have assisitve text present", function () {
        expect(description.innerText).to.eq("assistive text");
      });
    });

    describe("save required", function () {
      beforeEach(async function () {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`);
        await createComponent(form, {
          "save-required": "true",
          "data-assistive-text": "assistive text",
          "data-saved-label": "all good",
          "data-unsaved-label": "click me",
          "data-saving-label": "working on it",
        });
        ({ saveButton, form, input, description } = getElements());
      });

      it("should have the save label", function () {
        expect(saveButton.innerText).to.eq("click me");
      });

      it("should have no assisitve text present", function () {
        expect(description.innerText).to.eq("");
      });
    });

    describe("save required attribute changed", function () {
      beforeEach(async function () {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`);
        await createComponent(form, {
          "data-assistive-text": "assistive text",
          "data-saved-label": "all good",
          "data-unsaved-label": "click me",
          "data-saving-label": "working on it",
        });
        ({ saveButton, form, input, description } = getElements());
      });

      it("should update the label on change", function () {
        expect(saveButton.innerText).to.eq("all good");
        saveButton.setAttribute("save-required", "true");
        expect(saveButton.innerText).to.eq("click me");
        saveButton.removeAttribute("save-required");
        expect(saveButton.innerText).to.eq("all good");
      });

      it("should update the asssitive text on change", function () {
        expect(description.innerText).to.eq("assistive text");
        saveButton.setAttribute("save-required", "true");
        expect(description.innerText).to.eq("");
        saveButton.removeAttribute("save-required");
        expect(description.innerText).to.eq("assistive text");
      });

      it("should update the aria-disabled attribute on change", function () {
        expect(saveButton).to.have.attribute("aria-disabled", "true");
        saveButton.setAttribute("save-required", "true");
        expect(saveButton).to.have.attribute("aria-disabled", "false");
        saveButton.removeAttribute("save-required");
        expect(saveButton).to.have.attribute("aria-disabled", "true");
      });
    });

    describe("prevent unload", function () {
      let addEventListenerSpy;
      let removeEventListenerSpy;

      describe("no unload protection", function () {
        beforeEach(async function () {
          const html = createTemplate(ID);
          form = document.querySelector(`#${ID}`);
          await createComponent(form);
          ({ saveButton, form, input, description } = getElements());

          addEventListenerSpy = sandbox.spy(window, "addEventListener");
          removeEventListenerSpy = sandbox.spy(window, "removeEventListener");
        });

        it("does not set beforeunload listeners", function () {
          saveButton.saveRequired = true;
          expect(addEventListenerSpy).to.not.have.been.called;

          saveButton.saveRequired = false;
          expect(removeEventListenerSpy).to.not.have.been.called;
        });
      });

      describe("with unload protection", function () {
        beforeEach(async function () {
          const html = createTemplate(ID);
          form = document.querySelector(`#${ID}`);
          await createComponent(form, {
            "prevent-unload": "true",
          });
          ({ saveButton, form, input, description } = getElements());

          addEventListenerSpy = sandbox.spy(window, "addEventListener");
          removeEventListenerSpy = sandbox.spy(window, "removeEventListener");
        });

        it("sets beforeunload listeners", function () {
          saveButton.saveRequired = true;
          expect(addEventListenerSpy).to.have.been.called;

          saveButton.saveRequired = false;
          expect(removeEventListenerSpy).to.have.been.called;
        });
      });
    });
  });
});
