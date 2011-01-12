Lackie = {
  wip: false,
  enabled: true,
  baseUrl: "/lackie",

  createXMLHttpRequest: function() {
    try {
      return new XMLHttpRequest();
    } catch(e) {}
    try {
      return new ActiveXObject("Msxml2.XMLHTTP");
    } catch(e) {}
    throw new Error("XMLHttpRequest not supported");
  },

  yield: function() {
    if (Lackie.wip || !Lackie.enabled) {
      return;
    }
    var xhReq = Lackie.createXMLHttpRequest();
    function readyStateChange() {
      if (xhReq.readyState != 4 || xhReq.status == 404) {
        return;
      }
      Lackie.wip = true;
      try {
        Lackie.execute(xhReq.responseText);
      }
      finally {
        try {
          xhReq.destroy();
          xhReq = null;
        } catch(e) {}
      }
    }
    xhReq.open("GET", Lackie.url("/yield"), true);
    xhReq.onreadystatechange = readyStateChange;
    xhReq.send(null);
  },

  result: function(value) {
    var xhReq = Lackie.createXMLHttpRequest();
    var params = JSON.stringify(value);
    xhReq.open("POST", Lackie.url("/result"), true);
    xhReq.setRequestHeader("Content-type", "application/json");
    xhReq.setRequestHeader("Content-length", params.length);
    xhReq.setRequestHeader("Connection", "close");
    xhReq.send(params);
    Lackie.wip = false;
  },

  execute: function(command) {
    var result;
    try {
      result = { 'value': eval(command) };
    }
    catch(e) {
      result = { 'error': e.toString() };
    }
    Lackie.result(result);
  },

  log: function(message) {
    var logElement = document.getElementById("LackieLog");
    if (logElement) {
      logElement.innerHTML += '<div class="message">' + message + '</div>';
    }
    return message;
  },
  
  url: function(path) {
    var now = new Date();
    return Lackie.baseUrl + path + '?' + now.getTime().toString();
  }
}

if (window) {
  window.setInterval(Lackie.yield, 400);
}