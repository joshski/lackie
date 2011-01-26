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
  
  reload: function() {
    Lackie.enabled = false;
    var xhReq = Lackie.createXMLHttpRequest();
    xhReq.open("POST", Lackie.url("/result"), true);
    xhReq.onreadystatechange = function() {
      if (xhReq.readyState == 2 && xhReq.status == 200) {
        window.location.reload(true);
      }
    };
    xhReq.send('{ "value": "__RELOADING__" }');
  },

  yield: function() {
    if (Lackie.wip || !Lackie.enabled) {
      return;
    }
    Lackie.usingAjax(function(xhReq) {
      function readyStateChange() {
        if (xhReq.readyState != 4 || xhReq.status == 404) {
          return;
        }
        if (xhReq.responseText == '__RELOAD__') {
          Lackie.reload();
          return;
        }
   
        Lackie.wip = true;
        Lackie.execute(xhReq.responseText);
      }
           
      xhReq.open("GET", Lackie.url("/yield"), true);
      xhReq.onreadystatechange = readyStateChange;
      xhReq.send(null);    

    });

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