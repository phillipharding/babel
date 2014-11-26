(function($) {
"use strict";

    function getDaysOfMonth(now,m,y) {
        if (now.getMonth() == m && now.getFullYear() == y)
            return now.getDate();   /* if current month and current year return todays day as end of month day */
        switch(m) {
            case 1:
                return (((y % 400 == 0) || ((y % 4 == 0) && (y % 100 != 0) )))
                        ? 29     /* leap year */
                        : 28;    /* common year */
            case 0:
            case 2:
            case 4:
            case 6:
            case 7:
            case 9:
            case 11:
                return 31;
            default:
                return 30;
        }
    }
    function fom(m) {
        var ms = "00"+(m);
        return ms.substring(ms.length-2);
    }

$(function() {
    var months = ['January','February','March','April','May','June','July','August','September','October','November','December'],
        now = new Date(),
        nowY = now.getFullYear(),
        $e = $('.news-post-date-cloud ul');
    for(var c = 0, y = now.getFullYear(), m = now.getMonth(), i = 0; i < 12; i++, m--) {
        if (m < 0) {
            m = 11;
            y--;
        }
        
        if (c != y) {
            var $button = $("<div class='collapse-button'><span class='icon-bar'> </span><span class='icon-bar'> </span><span class='icon-bar'> </span></div>");
            $("<li/>")
                .addClass('year collapse-button-container')
                .append($('<h2>').attr('rel',nowY==y?0:1).text(y))
                .append($button)
                .appendTo($e);
            c = y;
        }
        var som = y + '-' + fom(m+1) + '-01T00:00:00Z',
            eom = y + '-' + fom(m+1) + '-' + fom(getDaysOfMonth(now,m,y)) + 'T23:59:59Z';
        $("<li/>")
            .addClass('month')
            .append($('<a>')
                    .attr('rel',12-i)
                    .attr('href', _spPageContextInfo.webServerRelativeUrl + '/SitePages/Date.aspx?StartDateTime='+som+'&EndDateTime='+eom+'&LMY='+months[m]+' '+y)
                    .attr('title', 'show all news in ' + months[m])
                    .text(months[m]) )
            .appendTo($e);
    }
    /* append an Archives link */
    var $l = $('<h2>')
                .append($('<a>')
                        .attr('href', _spPageContextInfo.webServerRelativeUrl + '/Lists/Posts/Archive.aspx')
                        .attr('title', 'show the news archives')
                        .text('Archives'));
    $("<li/>")
        .addClass('archive')
        .append($l)
        .appendTo($e);

    $e.stop().fadeIn(100);
    /* setup responsive menu collapser */
    $('.news-post-date-cloud .year .collapse-button').click(function(e) {
        $(this).parent().nextUntil('.year,.archive').toggleClass('reveal');
    });
});

})(jQuery);


