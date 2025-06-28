console.log("script.js loaded");
console.log("Blockly.JavaScript['car_light'] at load:", typeof Blockly !== 'undefined' ? Blockly.JavaScript['car_light'] : 'Blockly not loaded');

// 1. workspaceをvarで宣言しグローバル化
var workspace;


  // Blocklyロード後にすべて定義
  Blockly.Blocks['car_horn'] = {
    init: function() {
      this.appendDummyInput()
          .appendField("\u8B66\u544A\u97F3\u3092") // 警告音を
          .appendField(new Blockly.FieldDropdown([["\u9CF4\u3089\u3059", "PLAY"], ["\u6B62\u3081\u308B", "STOP"]]), "STATE") // 鳴らす, 止める
          .appendField("\u3059\u308B"); // する
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(160);
      this.setTooltip("\u8ECA\u306E\u8B66\u544A\u97F3\u3092\u9CF4\u3089\u3057\u305F\u308A\u6B62\u3081\u305F\u308A\u3057\u307E\u3059\u3002"); // 車の警告音を鳴らしたり止めたりします。
      this.setHelpUrl("");
    }
  };
  Blockly.Blocks['car_light'] = {
    init: function() {
      this.appendDummyInput()
          .appendField("\u30E9\u30A4\u30C8\u3092") // ライトを
          .appendField(new Blockly.FieldDropdown([["\u70B9\u706F", "ON"], ["\u6D88\u706F", "OFF"]]), "STATE") // 点灯, 消灯
          .appendField("\u3059\u308B"); // する
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(230);
      this.setTooltip("\u8ECA\u306E\u30E9\u30A4\u30C8\u3092\u70B9\u706F\u307E\u305F\u306F\u6D88\u706F\u3057\u307E\u3059\u3002"); // 車のライトを点灯または消灯します。
      this.setHelpUrl("");
    }
  };
  Blockly.Blocks['car_bgm'] = {
    init: function() {
      this.appendDummyInput()
          .appendField("BGM\u3092") // BGMを
          .appendField(new Blockly.FieldDropdown([["\u518D\u751F", "PLAY"], ["\u505C\u6B62", "STOP"]]), "STATE") // 再生, 停止
          .appendField("\u3059\u308B"); // する
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(20);
      this.setTooltip("BGM\u3092\u518D\u751F\u307E\u305F\u306F\u505C\u6B62\u3057\u307E\u3059\u3002"); // BGMを再生または停止します。
      this.setHelpUrl("");
    }
  };
  Blockly.Blocks['car_video'] = {
    init: function() {
      this.appendDummyInput()
          .appendField("\u52D5\u753B\u3092") // 動画を
          .appendField(new Blockly.FieldDropdown([["\u518D\u751F", "PLAY"], ["\u505C\u6B62", "STOP"]]), "STATE") // 再生, 停止
          .appendField("\u3059\u308B"); // する
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(60);
      this.setTooltip("\u52D5\u753B\u3092\u518D\u751F\u307E\u305F\u306F\u505C\u6B62\u3057\u307E\u3059\u3002"); // 動画を再生または停止します。
      this.setHelpUrl("");
    }
  };
  Blockly.Blocks['door_illum'] = {
    init: function() {
      this.appendDummyInput()
        .appendField("ドアイルミを")
        .appendField(new Blockly.FieldDropdown([["点灯", "ON"], ["消灯", "OFF"]]), "STATE")
        .appendField("する");
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(200);
      this.setTooltip("ドアパネルのイルミネーションを点灯または消灯します。");
      this.setHelpUrl("");
    }
  };
  // delayブロックの追加
  Blockly.Blocks['delay'] = {
    init: function() {
      this.appendDummyInput()
        .appendField("待つ")
        .appendField(new Blockly.FieldNumber(200, 0, 10000, 10), "TIME")
        .appendField("ミリ秒");
      this.setPreviousStatement(true, null);
      this.setNextStatement(true, null);
      this.setColour(120);
      this.setTooltip("指定したミリ秒だけ待ちます");
      this.setHelpUrl("");
    }
  };
  Blockly.JavaScript['car_horn'] = function(block, generator) {
    var state = block.getFieldValue('STATE');
    return 'setCarHorn("' + state + '");\n';
  };
  Blockly.JavaScript['car_light'] = function(block, generator) {
    var state = block.getFieldValue('STATE');
    return 'setCarLight("' + state + '");\n';
  };
  Blockly.JavaScript['car_bgm'] = function(block, generator) {
    var state = block.getFieldValue('STATE');
    if (state === 'PLAY') {
      return 'setBgmPlaying(true);\n';
    } else {
      return 'setBgmPlaying(false);\n';
    }
  };
  Blockly.JavaScript['car_video'] = function(block, generator) {
    var state = block.getFieldValue('STATE');
    if (state === 'PLAY') {
      return 'setVideoPlaying(true);\n';
    } else {
      return 'setVideoPlaying(false);\n';
    }
  };
  Blockly.JavaScript['door_illum'] = function(block, generator) {
    var state = block.getFieldValue('STATE');
    return 'setDoorIllum("' + state + '");\n';
  };
  Blockly.JavaScript['delay'] = function(block, generator) {
    var time = block.getFieldValue('TIME');
    return 'await delay(' + time + ');\n';
  };
  // forBlock形式も追加
  Blockly.JavaScript.forBlock = Blockly.JavaScript.forBlock || {};
  Blockly.JavaScript.forBlock['car_horn'] = Blockly.JavaScript['car_horn'];
  Blockly.JavaScript.forBlock['car_light'] = Blockly.JavaScript['car_light'];
  Blockly.JavaScript.forBlock['car_bgm'] = Blockly.JavaScript['car_bgm'];
  Blockly.JavaScript.forBlock['car_video'] = Blockly.JavaScript['car_video'];
  Blockly.JavaScript.forBlock['door_illum'] = Blockly.JavaScript['door_illum'];
  Blockly.JavaScript.forBlock['delay'] = Blockly.JavaScript['delay'];  
  console.log("car_light generator defined:", window.Blockly.JavaScript['car_light']);
  console.log("window.Blockly.JavaScript:", window.Blockly.JavaScript); // 追加

  // injectはgenerator定義の後に
  workspace = Blockly.inject('blocklyDiv', {
    media: 'https://unpkg.com/blockly/media/',
    toolbox: '<xml>' +
      '<block type="car_light"/>' +
      '<block type="car_horn"/>' +
      '<block type="car_bgm"/>' +
      '<block type="car_video"/>' +
      '<block type="door_illum"/>' +
      '<block type="controls_repeat_ext"><value name="TIMES"><shadow type="math_number"><field name="NUM">10</field></shadow></value></block>' +
      '<block type="controls_whileUntil"/>' +
      '<block type="controls_if"/>' +
      '<block type="delay"/>' +
      '<block type="text"/>' +
    '</xml>'
  });
  window.workspace = workspace; // デバッグ用にグローバル公開

  // --- Application-specific logic ---
  var hornSound = new Audio('sounds/horn.mp3');
  var bgmPlaying = false;

  function setCarLight(state) {
    var indicator = document.getElementById('car-light-indicator');
    console.log('[DEBUG] setCarLight:', state, indicator);
    if (indicator) {
      if (state === "ON") {
        indicator.style.opacity = 1;
        indicator.style.filter = "drop-shadow(0 0 16px yellow)";
      } else {
        indicator.style.opacity = 0.2;
        indicator.style.filter = "none";
      }
    }
  }

  // BGM表示用関数
  function setBgmPlaying(isPlaying) {
    console.log('[DEBUG] setBgmPlaying:', isPlaying);
    bgmPlaying = isPlaying;
    var bgmIndicator = document.getElementById('bgm-indicator');
    if (bgmIndicator) {
      bgmIndicator.style.display = isPlaying ? 'block' : 'none';
    }
  }

  function setCarHorn(state) {
    console.log('[DEBUG] setCarHorn:', state);
    if (state === "PLAY") {
      playBeep();
    } else {
      stopBeep();
    }
  }

  function setVideoPlaying(isPlaying) {
    console.log('[DEBUG] setVideoPlaying:', isPlaying);
    var videoIndicator = document.getElementById('video-indicator');
    if (videoIndicator) {
      videoIndicator.style.display = isPlaying ? 'block' : 'none';
    }
  }

  function setDoorIllum(state) {
    var left = document.getElementById('door-illum-left');
    var right = document.getElementById('door-illum-right');
    if (left) {
      left.style.opacity = (state === "ON") ? 1 : 0.2;
      left.style.filter = (state === "ON") ? "drop-shadow(0 0 12px #0ff)" : "none";
    }
    if (right) {
      right.style.opacity = (state === "ON") ? 1 : 0.2;
      right.style.filter = (state === "ON") ? "drop-shadow(0 0 12px #0ff)" : "none";
    }
  }

  function playBeep(frequency = 880, duration = 200, volume = 0.2) {
    if (window._beepCtx) {
      stopBeep();
    }
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const oscillator = ctx.createOscillator();
    const gain = ctx.createGain();
    oscillator.type = 'sine';
    oscillator.frequency.value = frequency;
    gain.gain.value = volume;
    oscillator.connect(gain);
    gain.connect(ctx.destination);
    oscillator.start();
    window._beepCtx = ctx;
    window._beepOsc = oscillator;
    setTimeout(() => {
      stopBeep();
    }, duration);
  }

  function stopBeep() {
    if (window._beepOsc) {
      window._beepOsc.stop();
      window._beepOsc.disconnect();
      window._beepOsc = null;
    }
    if (window._beepCtx) {
      window._beepCtx.close();
      window._beepCtx = null;
    }
  }

  document.getElementById('runButton').addEventListener('click', async function() {
    var code = Blockly.JavaScript.workspaceToCode(workspace);
    try {
      await eval(`(async()=>{${code}})()`);
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

  // delay用の関数を追加
  async function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }