require("./setup");

const expect = require("chai").expect;
const utilities = require("../app/javascript/src/utilities.js");

describe("Test", function () {
  describe("templates", function () {
    before(function () {
    });

    it("should have a window available", function () {
      expect(typeof window).to.equal(typeof (new Object()));
    });

    it("should have a document available", function () {
      expect(typeof document).to.equal(typeof (new Object()));
    });

    it("should have a viable DOM", function () {
      expect(document.title).to.equal("Test document");
    });
  });

  describe("script", function () {
    it("should have loaded jQuery", function () {
      expect(typeof jQuery.fn).to.equal("object");
      expect(typeof jQuery.fn.jquery).to.equal("string");
    });

    it("should have jQuery attached to window", function () {
      expect(typeof window.jQuery).to.equal("function");
    });

    it("should find elements with jQuery", function () {
      expect($(document).find("h1").text()).to.equal("Testing document");
    });

    it("should load jQueryUI", function () {
      expect(typeof jQuery.ui).to.equal("object");
    });
  });

  describe("resources", function () {
    it("should be loaded when required", function () {
      expect(typeof utilities.mergeObjects).to.equal(typeof Function);
    });
  });
});
