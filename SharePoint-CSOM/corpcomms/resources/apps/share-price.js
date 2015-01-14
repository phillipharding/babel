(function($) {
"use strict";
window.corpcomms = window.corpcomms || {};
corpcomms.shareprice = function() {
    var _module = { start: corpcomms$shareprice$start };
    return _module;

    function corpcomms$shareprice$start() {
        if (typeof(prices) !== 'undefined') {
            var p = parseInt(prices), lc = parseInt(lastclose),
                updown = (p > lc) ? '+' : (p < lc) ? '-' : '';
            document.getElementById('sp-date').innerHTML = String.format("{0} RB - {1} {2}:{3} {4}", code, dateddmmmyyyy, hour, min, timezone);
            document.getElementById('sp-incdecpc').innerHTML = String.format("{0}{1}", (updown === '-' ? '' : updown), parseInt(change));
            document.getElementById('sp-perc').innerHTML = String.format("{0}%", perc);
            document.getElementById('sp-high').innerHTML = dayhigh;
            document.getElementById('sp-low').innerHTML = daylow;
            document.getElementById('sp-volume').innerHTML = dayvolume;
            document.getElementById('sp-price').innerHTML = prices;
            var shareprice = document.getElementById('share-price');
            if (updown === '-') shareprice.className = 'share-price bg-grey down';
            else if (updown === '+') shareprice.className = 'share-price bg-grey';
            else shareprice.className = 'share-price bg-grey nochange';
        }
        $('#share-price-loading').fadeOut().remove();
        $('.share-price').fadeIn();
    }
}();

$(corpcomms.shareprice.start);

})(jQuery);
