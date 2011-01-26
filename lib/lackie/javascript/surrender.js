Lackie = {
  wip: false,
  enabled: true,
  baseUrl: "/lackie",

  yield: function() {
    if (Lackie.wip || !Lackie.enabled) {
      return;
    }
    Lackie.usingAjax(function(xhReq) {
      xhReq.open("GET", Lackie.url("/yield"), true);
      xhReq.onreadystatechange = function () {
        if (xhReq.readyState != 4 || xhReq.status == 404) {
          return;
        }
        if (xhReq.responseText == '__RELOAD__') {
          Lackie.reload();
          return;
        }
        Lackie.wip = true;
        Lackie.execute(xhReq.responseText);
      };
      xhReq.send(null);
    });

  },
  
  result: function(value) {
    Lackie.usingAjax(function(xhReq) {
      var params = JSON.stringify(value);
      xhReq.open("POST", Lackie.url("/result"), true);
      xhReq.setRequestHeader("Content-type", "application/json");
      xhReq.setRequestHeader("Content-length", params.length);
      xhReq.setRequestHeader("Connection", "close");
      xhReq.send(params);
    });
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
  
  reload: function() {
    Lackie.enabled = false;
    Lackie.usingAjax(function(xhReq) {
      xhReq.open("POST", Lackie.url("/result"), true);
      xhReq.onreadystatechange = function() {
        if (xhReq.readyState == 2 && xhReq.status == 200) {
          window.location.reload(true);
        }
      };
      xhReq.send('{ "value": "__RELOADING__" }');
    });
  },
  
  log: function(message) {
    var logElement = document.getElementById("LackieLog");
    if (logElement) {
      logElement.innerHTML += '<div class="message">' + message + '</div>';
    }
    return message;
  },
  
  createXMLHttpRequest: function() {
    try {
      return new XMLHttpRequest();
    } catch(e) {}
    try {
      return new ActiveXObject("Msxml2.XMLHTTP");
    } catch(e) {}
    throw new Error("XMLHttpRequest not supported");
  },
  
  usingAjax: function(callback) {
    var xhReq = Lackie.createXMLHttpRequest();
    try {
        callback(xhReq);
    }
    finally {
      try {
        if (typeof xhReq.destroy == 'function')
          xhReq.destroy();
        delete xhReq;
      } catch(e) {}
    }
  },
  
  url: function(path) {
    var now = new Date();
    return Lackie.baseUrl + path + '?' + now.getTime().toString();
  }
}

if (window) {
  window.setInterval(Lackie.yield, 400);
}