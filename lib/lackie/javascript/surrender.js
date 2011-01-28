Lackie = {
  wip: false,
  enabled: true,
  baseUrl: "/lackie",

  yield: function() {
    if (Lackie.wip || !Lackie.enabled) {
      return;
    }
    Lackie.get("/yield", function(body) {
      var json = JSON.parse(body);
      Lackie.wip = true;
      Lackie.execute(json.command, json.id);
    });
  },
  
  result: function(value) {
    var params = JSON.stringify(value);
    Lackie.post("/result", params, function() {
      Lackie.wip = false;
    });
  },

  execute: function(command, id) {
    if (command.indexOf('Lackie.reload()') == 0) {
      Lackie.reload(id);
      return;
    }
    
    var result;
    try {
      result = { id: id, value: eval(command) };
    }
    catch(e) {
      result = { id: id, error: e.toString() };
    }
    Lackie.result(result);
  },
  
  reload: function(id) {
    Lackie.enabled = false;
    Lackie.post("/result", '{ "id": ' + id + ', "value": "reloading" }', function() {
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
    var xhReq = Lackie.createXMLHttpRequest();
    function readyStateChange() {
        if (xhReq.readyState != 4) {
            return;
        }
        var body = xhReq.responseText;
        var status = xhReq.status;
        Lackie.disposeXMLHttpRequest(xhReq);
        if (status == 200) {
            bodyCallback(body);
        }
    }
    xhReq.open("GET", Lackie.url(path), true);
    xhReq.onreadystatechange = readyStateChange;
    xhReq.send(null);
  },

  post: function(path, json, callback) {
    var xhReq = Lackie.createXMLHttpRequest();
    function readyStateChange() {
        if (xhReq.readyState != 4) {
            return;
        }
        var status = xhReq.status;
        Lackie.disposeXMLHttpRequest(xhReq);
        if (status == 200) {
            callback();
        }
    }
    xhReq.open("POST", Lackie.url(path), true);
    xhReq.setRequestHeader("Content-type", "application/json");
    xhReq.setRequestHeader("Content-length", json.length);
    xhReq.setRequestHeader("Connection", "close");
    xhReq.onreadystatechange = readyStateChange;
    xhReq.send(json);
  },

  
  disposeXMLHttpRequest: function(xhReq) {
    try {
      if (typeof xhReq.destroy == 'function') {
        xhReq.destroy();
	  }
    } catch(e) {}
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
  
  url: function(path) {
    var now = new Date();
    return Lackie.baseUrl + path + '?' + now.getTime().toString();
  }
}

if (window) {
  window.setInterval(Lackie.yield, 400);
}