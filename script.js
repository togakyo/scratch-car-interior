console.log("script.js loaded");
console.log("Blockly.JavaScript['car_light'] at load:", typeof Blockly !== 'undefined' ? Blockly.JavaScript['car_light'] : 'Blockly not loaded');

// 1. workspaceをvarで宣言しグローバル化
var workspace;


  // Blocklyロード後にすべて定義
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
  // generator定義をwindow.Blocklyで明示的に
  //window.Blockly.JavaScript['car_horn'] = function(block) {
  //  var state = block.getFieldValue('STATE');
  //  return 'setCarHorn("' + state + '\');\n';
  //};
  Blockly.JavaScript.forBlock['car_horn'] = function(block, generator) {
  const state = block.getFieldValue('STATE');
  return `setCarHorn("${state}");\n`;
  };
  //window.Blockly.JavaScript['car_light'] = function(block) {
  //  var state = block.getFieldValue('STATE');
  //  return 'setCarLight("' + state + '");\n';
  //};
  Blockly.JavaScript.forBlock['car_light'] = function(block, generator) {
  const state = block.getFieldValue('STATE');
  return `setCarLight("${state}");\n`;
  };
  console.log("car_light generator defined:", window.Blockly.JavaScript['car_light']);
  console.log("window.Blockly.JavaScript:", window.Blockly.JavaScript); // 追加

  // injectはgenerator定義の後に
  workspace = Blockly.inject('blocklyDiv', {
    media: 'https://unpkg.com/blockly/media/',
    toolbox: '<xml><block type="car_light"></block><block type="car_horn"></block><block type="controls_if"></block><block type="text"></block></xml>'
  });
  window.workspace = workspace; // デバッグ用にグローバル公開

  // --- Application-specific logic ---
  var hornSound = new Audio('sounds/horn.mp3');

  function setCarLight(state) {
    var lightOverlay = document.getElementById('car-light-overlay');
    lightOverlay.style.display = (state === "ON") ? "block" : "none";
  }

  function setCarHorn(state) {
    if (state === "PLAY") {
      hornSound.play();
    } else {
      hornSound.pause();
      hornSound.currentTime = 0;
    }
  }

  document.getElementById('runButton').addEventListener('click', function() {
    var code = Blockly.JavaScript.workspaceToCode(workspace);
    try {
      eval(code);
    } catch (e) {
      console.error(e);
    }
  });

  // ワークスペースをクリアしてからブロックをロード
  workspace.clear();
  var xmlText = '<xml>' +
    '  <block type="car_light" x="70" y="70">' +
    '    <field name="STATE">ON</field>' +
    '    <next>' +
    '      <block type="car_horn">' +
    '        <field name="STATE">PLAY</field>' +
    '      </block>' +
    '    </next>' +
    '  </block>' +
    '</xml>';
  var parser = new DOMParser();
  var xmlDom = parser.parseFromString(xmlText, 'text/xml');
  Blockly.Xml.domToWorkspace(xmlDom.documentElement, workspace);