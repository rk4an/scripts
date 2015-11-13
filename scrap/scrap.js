var x = require('x-ray')();
var push = require('pushover-notifications');

//pushover settings
var user = "CHANGEME";
var token = "CHANGEME";

//scrap settings
var url = "http://the-big-bang-theory-streaming.com/saison-9";
var title = "TBBT news";
var selector = [".glyphicon-chevron-right + .a-panel-head-gauche"];
var refresh = 2 *60 * 60 * 1000;
var data = -1;

//run
setIntervalAndExecute(scrap, refresh);

//functions
function setIntervalAndExecute(fn, t) {
    fn();
    return (setInterval(fn, t));
}

function scrap() {
    x(url,
        selector
    )(function (err, obj) {
        console.log(obj);

        if(data == -1) {
            data = obj.length;
        }

        if (obj.length > data) {
            data = obj.length;
            send(obj[0], title);
        }
    })
}

function send(message, title) {
    var p = new push({
        user: user,
        token: token
    });

    var msg = {
        message: message,
        title: title,
        sound: 'magic',
        device: 'devicename',
        priority: 1
    };

    p.send(msg, function (err, result) {
        if (err) {
            throw err;
        }

        console.log(result);
    });
}
