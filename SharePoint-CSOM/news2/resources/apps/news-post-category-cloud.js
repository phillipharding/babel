(function($) {
"use strict";

window.news = window.news || {};
news.categorycloud = news.categorycloud || {};
news.categorycloud.getCategories = function() {
    var
        p = new $.Deferred(),
        r = {
            url: _spPageContextInfo.webServerRelativeUrl + "/_api/web/lists/getbytitle('Categories')/items?$select=Id,Title&$orderby=Title",
            type: 'GET',
            headers: {
                ACCEPT: _spPageContextInfo.siteClientTag.match(/^\d+\$\$16./g)
                            ? 'application/json;odata=minimalmetadata' /* SPO/Office365 */
                            : 'application/json;odata=verbose' /* OnPremise */
            }
        };
    $.ajax(r)
        .done(function(response) {
            var data = (response.value || response.d.results || response.d);
            p.resolve(data);
        })
        .fail(function (xhrObj, textStatus, err) {
            var e = JSON.parse(xhrObj.responseText),
                err = e.error || e["odata.error"],
                m = '<div style="color:red;font-family:Calibri,Verdana,Arial;font-size:1.2em;">Exception<br/>&raquo; ' +
                       ((err && err.message && err.message.value) ? err.message.value : (xhrObj.status + ' ' + xhrObj.statusText))
                       +' <br/>&raquo; '+r.url+'</div>';
          p.resolve({ success: false, error: m, uri: r.url });
        });
    return p.promise();
}
news.categorycloud.render = function(data) {
    if (data.error) {
        $('.news-post-category-cloud').html(data.error);
        return;
    }
    var $e = $('.news-post-category-cloud ul');
    var $button = $("<div class='collapse-button'><span class='icon-bar'> </span><span class='icon-bar'> </span><span class='icon-bar'> </span></div>");
    $("<li/>")
        .addClass('title collapse-button-container')
        .append($('<h2>').text('Categories'))
        .append($button)
        .appendTo($e);
    $.each(data, function(i,e) {
        $("<li/>")
            .addClass('category')
            .append($('<a>')
                    .attr('href', _spPageContextInfo.webServerRelativeUrl + '/SitePages/Categories.aspx?CategoryId='+e.Id)
                    .attr('title', 'show all news for ' + e.Title)
                    .text(e.Title) )
            .appendTo($e);
    });
    $e.stop().fadeIn(100);
    /* setup responsive menu collapser */
    $('.news-post-category-cloud .title .collapse-button').click(function(e) {
        $(this).parent().nextUntil('.title').toggleClass('reveal');
    });
}
news.categorycloud.start = function() {
    news.categorycloud.getCategories()
        .done(news.categorycloud.render);
}

$(news.categorycloud.start);

})(jQuery);
