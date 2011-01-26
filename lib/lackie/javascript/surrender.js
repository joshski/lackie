Lackie = {
  wip: false,
  enabled: true,
  baseUrl: "/lackie",

  yield: function() {
    if (Lackie.wip || !Lackie.enabled) {
      return;
    }
    Lackie.get("/yield", function(body) {
      if (body.indexOf('Lackie.reload()') == 0) {
        Lackie.reload();
        return;
      }
      Lackie.wip = true;
      Lackie.execute(body);
    });
  },
  
  result: function(value) {
    var params = JSON.stringify(value);
    Lackie.post("/result", params, function() {
      Lackie.wip = false;
    });
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
    Lackie.post("/result", '{ "value": "reloading" }', function() {
      window.location.reload(true);
    });
  },
  
  log: function(message) {
    var logElement = document.getElementById("LackieLog");
    if (logElement) {
      logElement.innerHTML += '<div class="message">' + message + '</div>';
    }
    return message;
  },
  
  get: function(path, bodyCallback) {
    Lackie.usingAjax(function(xhReq) {
      xhReq.open("GET", Lackie.url(path), true);
      xhReq.onreadystatechange = function () {
        if (xhReq.readyState != 4 || xhReq.status != 200) {
          return;
        }
        bodyCallback(xhReq.responseText);
      };
      xhReq.send(null);
    });
  },
  
  post: function(path, params, callback) {
    Lackie.usingAjax(function(xhReq) {
      xhReq.open("POST", Lackie.url(path), true);
      xhReq.onreadystatechange = function () {
        if (xhReq.readyState != 2 || xhReq.status != 200) {
          return;
        }
        callback();
      };
      xhReq.setRequestHeader("Content-type", "application/json");
      xhReq.setRequestHeader("Content-length", params.length);
      xhReq.setRequestHeader("Connection", "close");
      xhReq.send(params);
    });
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