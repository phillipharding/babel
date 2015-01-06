(function($) {
"use strict";

function getQueryStringParameter(urlParameterKey) {
    var qparams = document.URL.split('?');
    if (qparams.length < 2) return null;
    var params = qparams[1].split('&');
    var strParams = '';
    for (var i = 0; i < params.length; i = i + 1) {
        var singleParam = params[i].split('=');
        if (singleParam[0] == urlParameterKey)
            return decodeURIComponent(singleParam[1]);
    }
    return  null;
}

window.corpcomms = window.corpcomms || {};
corpcomms.shareprice = function() {
    var
        _module = {
            start: start
        };
    return _module;

    function start() {
    }
}();

$(corpcomms.shareprice.start);

})(jQuery);
