require("../setup");

describe("FlowConnectorLine", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconnectorline-for-testing-properties-container";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorLine(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    it("should return the name", function() {
      expect(created.lines.length).to.equal(3);
      expect(created.lines[0].name).to.equal("forward1");
      expect(created.lines[1].name).to.equal("up");
      expect(created.lines[2].name).to.equal("forward2");
    });

    it("should return the type", function() {
      expect(created.lines.length).to.equal(3);
      expect(created.lines[0].type).to.equal("horizontal");
      expect(created.lines[1].type).to.equal("vertical");
      expect(created.lines[2].type).to.equal("horizontal");
    });

    it("should return the path value", function() {
      expect(created.lines.length).to.equal(3);
      expect(created.lines[0].path).to.equal("h70");
      expect(created.lines[1].path).to.equal("v-230");
      expect(created.lines[2].path).to.equal("h-2");
    });

    it("should return the range", function() {
      expect(created.lines[0].range.length).to.equal(70);
      expect(created.lines[0].range[0]).to.equal(1451);
      expect(created.lines[1].range[0]).to.equal(303);
    });

    it("should set the range passed", function() {
      var range = [ 1450, 1451, 1452, 1453, 1454, 1455, 1456, 1457,
                    1458, 1459, 1460, 1461, 1462, 1463, 1464, 1465,
                    1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473,
                    1474, 1475, 1476, 1477, 1478, 1479, 1480, 1481,
                    1482, 1483, 1484, 1485, 1486, 1487, 1488, 1489,
                    1490, 1491, 1492, 1493, 1494, 1495, 1496, 1497,
                    1498, 1499, 1500, 1501, 1502, 1503, 1504, 1505,
                    1506, 1507, 1508, 1509, 1510, 1511, 1512, 1513,
                    1514, 1515, 1516, 1517, 1518, 1519
                  ];

      created.lines[0].range = [ 1450, 100];
      expect(created.lines[0].range).to.eql(range);
    });

  });

});
