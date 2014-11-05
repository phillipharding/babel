(function($) {
"use strict";
var options = {
    maxTake: 3,
    hasCategory: false
};

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

function getFilter() {
    var
        now = new Date(),
        sdt = null, 
        edt = null,
        cid = getQueryStringParameter('CategoryId');
    edt = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);
    sdt = new Date(edt-(30*24*60*60*1000));
    sdt.setHours(1);
    sdt.setMinutes(0);
    sdt.setSeconds(0);
    var filter = String.format("&$filter=PublishedDate ge datetime'{0}' and PublishedDate le datetime'{1}'", sdt.toISOString(), edt.toISOString());
    if (cid) {
        filter += String.format(" and PostCategoryId eq {0}", cid);
        options.hasCategory = true;
    }
    console.log('news.popular.getFilter>> '+filter);
    return filter;
}

window.news = window.news || {};
news.popular = news.popular || {};
news.popular.getPosts = function() {
    var
        p = new $.Deferred(),
        r = {
            url: _spPageContextInfo.webServerRelativeUrl + "/_api/web/lists/getbytitle('Posts')/items?$select=Id,Title,PublishedDate,LikesCount,NumCommentsId,PostCategoryId&$orderby=PublishedDate desc"
                    + getFilter(),
            type: 'GET',
            headers: {
                ACCEPT: 'application/json;odata=minimalmetadata'
            }
        };
    $.ajax(r)
        .done(function(response) {
            var data = (response.value || response.d.results || response.d);
            var populardata = [];
            $.each(data, function(i,e) {
                if ((e.LikesCount && e.LikesCount > 0) || (e.NumCommentsId && e.NumCommentsId > 0)) {
                    populardata.push(e);
                }
            });
            p.resolve(populardata);
        })
        .fail(function (xhrObj, textStatus, err) {
            var e = null,
                m = '<div style="color:red;font-family:Calibri,Verdana,Arial;font-size:1.2em;">Exception<br/>&raquo; ' +
                       ((e && e.error && e.error.message && e.error.message.value) ? e.error.message.value : (xhrObj.status + ' ' + xhrObj.statusText))
                       +' <br/>&raquo; '+r.url+'</div>';
          p.resolve({ success: false, error: m, uri: r.url });
        });
    return p.promise();
}
news.popular.render = function(data) {
    if (data.error) {
        $('.news-post-popular').html(data.error);
        return;
    }
    if (!data.length) return;

    var $e = $('.news-post-popular ul'),
        tip = options.hasCategory ? 'popular articles in this category from the last 30 days' : 'popular articles from the last 30 days';
    $("<li/>")
        .addClass('title')
        .append($('<h2>').attr('title',tip).text('Popular'))
        .appendTo($e);
    $.each(data, function(i,e) {
        $("<li/>")
            .addClass('article')
            .append($('<a>')
                    .attr('href', _spPageContextInfo.webServerRelativeUrl + '/Lists/Posts/Post.aspx?ID='+e.Id)
                    .attr('title', String.format("{0} {1}, {2} {3}", 
                                        e.LikesCount ? e.LikesCount : 0, e.LikesCount != 1 ? 'Likes' : 'Like', e.NumCommentsId ? e.NumCommentsId : 0, e.NumCommentsId != 1 ? 'Comments' : 'Comment'))
                    .text(e.Title) )
            .appendTo($e);
    });
    $e.stop().fadeIn(100);
}
news.popular.start = function() {
    news.popular.getPosts()
        .done(news.popular.render);
}

$(news.popular.start);

})(jQuery);
