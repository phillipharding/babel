(function($) {
   "use strict";
   window.corpcomms = window.corpcomms || {};
   corpcomms.favourites = function() {
      var
         _canEditRb = false, 
         _module = {
         start: corpcomms$favourites$start
      };
      return _module;

      function corpcomms$favourites$getFavourites(listName, allItems) {
         var
            p = new $.Deferred(),
            r = {
               url: _spPageContextInfo.webServerRelativeUrl + "/_api/web/lists/GetByTitle('"+listName+"')/items?$select=URL,Comments&$orderby=URL",
               type: 'GET',
               headers: {
                  Accept: 'application/json;odata=minimalmetadata'
               }
            };
         if (typeof(allItems) === 'undefined' || (typeof(allItems) === 'boolean' && !allItems)) {
            r.url += "&$filter=AuthorId eq "+ _spPageContextInfo.userId;
         }

         $.ajax(r).done(function(response) {
            var
               data = (response.value || response.d.results || response.d),
               model = $.map(data, function(e, i) {
                  return { Url: e.URL.Url, Description: e.URL.Description, Notes: e.Comments };
               });
            p.resolve(model);
         }).fail(function(xhrObj, textStatus, err) {
            var
               e = JSON.parse(xhrObj.responseText),
               err = e.error || e["odata.error"],
               m = 'corpcomms$favourites$getFavourites("'+listName+'")>> ' +
                     ((err && err.message && err.message.value) ? err.message.value : (xhrObj.status + ' ' + xhrObj.statusText));
            if (window.console) { window.console.log(m); }
            p.resolve(false);
         });
         return p.promise();
      }

      function corpcomms$favourites$getWebPermission() {
         var
            p = new $.Deferred(),
            r = {
               url: _spPageContextInfo.webServerRelativeUrl + '/_api/web/effectiveBasePermissions',
               type: 'GET',
               headers: {
                  Accept: 'application/json;odata=verbose'
               }
            };
         EnsureScriptFunc('SP.js', null, function() {
            if (window.console) console.log('(favourites.js)>> SP.js loaded');
            $.ajax(r)
               .done(function(data) {
                  if (data && data.d && data.d.EffectiveBasePermissions) {
                     var permissions = new SP.BasePermissions();
                     permissions.fromJson(data.d.EffectiveBasePermissions);
                     _canEditRb = permissions.has(SP.PermissionKind.addAndCustomizePages);
                     p.resolve(_canEditRb);
                  }
               }).fail(function(xhrObj, textStatus, err) {
                  p.resolve(false);
               });
         });
         return p.promise();
      }

      function corpcomms$favourites$render(data, $parent) {
         var html = [''];
         try {

            var tenant = location.href.match(/^http[s]?:\/\/[^\/]*/gi),
               re = new RegExp("^"+tenant[0], "gi");
            $.each(data, function(i, e) {
               var
                  isInt = e.Url && e.Url.length && re.exec(e.Url),
                  target = isInt && isInt.length ? '' : 'blank';
               var ehtml = String.format("<span><a href='{0}' title='{1}' target='{2}'>{1}</a></span>", e.Url, e.Description, target);
               html.push(ehtml);
            });
         } catch(e) {
            html = ['<span style="color:red;font-weight:bold;">!Exception: ' + e.toString()+"</span>"];
         }
         $parent.html(html.join(''));
      }

      function corpcomms$favourites$start() {
         var
            deps = [
               corpcomms$favourites$getWebPermission(),
               corpcomms$favourites$getFavourites('My Favourites'),
               corpcomms$favourites$getFavourites('Rb Favourites', true)
            ];
         $.when.apply($, deps)
            .done(function(canEditRb, myFavourites, rbFavourites) {
               if (window.console) { window.console.log('(favourites.js)>> canEditRb ['+_canEditRb+':'+canEditRb+']'); }

               var $favs = $('#favourites-wrapper');
               corpcomms$favourites$render(myFavourites, $favs.find('.myfavourites .container').first());
               corpcomms$favourites$render(rbFavourites, $favs.find('.rbfavourites .container').first());
               corpcomms$favourites$show();
            });         
      }

      function corpcomms$favourites$show() {
         $('#myfavourites-edit').attr('href', _spPageContextInfo.webServerRelativeUrl + '/Lists/MyFavourites');
         if (!_canEditRb)
            $('#rbfavourites-edit').remove();
         else 
            $('#rbfavourites-edit').attr('href', _spPageContextInfo.webServerRelativeUrl + '/Lists/RbFavourites');

         $('.favourites-inner').fadeIn(500, function() {
            $('#favourites-loading').fadeOut(500);
         });
      }
   }();

   $(corpcomms.favourites.start);

})(jQuery);