window.onload = function() {
  Blockly.Blocks['car_horn'] = {
    init: function() {
      this.appendDummyInput()
          .appendField("警告音を")
          .appendField(new Blockly.FieldDropdown([["鳴らす", "PLAY"], ["止める", "STOP"]]), "STATE")
          .appendField("する");
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(160);
      this.setTooltip("車の警告音を鳴らしたり止めたりします。");
      this.setHelpUrl("");
    }
  };

  Blockly.JavaScript['car_horn'] = function(block) {
    var state = block.getFieldValue('STATE');
    var code = 'setCarHorn("' + state + '");\n';
    return code;
  };

  Blockly.Blocks['car_light'] = {
    init: function() {
      this.appendDummyInput()
          .appendField("ライトを")
          .appendField(new Blockly.FieldDropdown([["点灯", "ON"], ["消灯", "OFF"]]), "STATE")
          .appendField("する");
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(230);
      this.setTooltip("車のライトを点灯または消灯します。");
      this.setHelpUrl("");
    }
  };

  Blockly.JavaScript['car_light'] = function(block) {
    var state = block.getFieldValue('STATE');
    var code = 'setCarLight("' + state + '");\n';
    return code;
  };

  var workspace = Blockly.inject('blocklyDiv', {
    media: 'https://unpkg.com/blockly/media/',
    toolbox: '<xml><block type="car_light"></block><block type="car_horn"></block><block type="controls_if"></block><block type="text"></block></xml>'
  });

  function setCarLight(state) {
    console.log("ライトを" + (state === "ON" ? "点灯" : "消灯") + "しました。");
    var lightOverlay = document.getElementById('car-light-overlay');
    if (state === "ON") {
      lightOverlay.style.display = "block";
    } else {
      lightOverlay.style.display = "none";
    }
  }

  function setCarHorn(state) {
    console.log("警告音を" + (state === "PLAY" ? "鳴らしました" : "止めました") + "。");
    var hornSound = new Audio('https://www.soundjay.com/buttons/beep-07.mp3'); // 著作権フリーの短い効果音のURL
    if (state === "PLAY") {
      hornSound.play();
    } else {
      hornSound.pause();
      hornSound.currentTime = 0;
    }
  }

  workspace.addChangeListener(function(event) {
    if (event.type == Blockly.Events.BLOCK_CHANGE ||
        event.type == Blockly.Events.BLOCK_CREATE ||
        event.type == Blockly.Events.BLOCK_DELETE ||
        event.type == Blockly.Events.BLOCK_MOVE) {
      // コードの自動実行を削除
    }
  });

  document.getElementById('runButton').addEventListener('click', function() {
    var code = Blockly.JavaScript.workspaceToCode(workspace);
    try {
      eval(code);
    } catch (e) {
      console.error(e);
    }
  });

  var xmlText = '<xml>' +
    '  <block type="car_light" x="70" y="70">' +
    '    <field name="STATE">ON</field>' +
    '    <next>' +
    '      <block type="car_horn">' +
    '        <field name="STATE">PLAY</field>' +
    '        <next>' +
    '          <block type="car_light">' +
    '            <field name="STATE">OFF</field>' +
    '            <next>' +
    '              <block type="car_horn">' +
    '                <field name="STATE">STOP</field>' +
    '              </block>' +
    '            </next>' +
    '          </block>' +
    '        </next>' +
    '      </block>' +
    '    </next>' +
    '  </block>' +
    '</xml>';

  var parser = new DOMParser();
  var xmlDom = parser.parseFromString(xmlText, 'text/xml');
  Blockly.Xml.domToWorkspace(xmlDom.documentElement, workspace);
};