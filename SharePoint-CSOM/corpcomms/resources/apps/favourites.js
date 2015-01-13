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

      function corpcomms$favourites$start() {
         var
            deps = [
               corpcomms$favourites$getWebPermission()
            ];
         $.when.apply($, deps)
            .done(function(canEditRb) {
               if (window.console) { window.console.log('(favourites.js)>> canEditRb ['+_canEditRb+':'+canEditRb+']'); }

               corpcomms$favourites$show();
            });         
      }

      function corpcomms$favourites$show() {
         $('#myfavourites-edit').attr('href', _spPageContextInfo.webServerRelativeUrl + '/Lists/MyFavourites');
         if (!_canEditRb)
            $('#rbfavourites-edit').remove();
         else 
            $('#rbfavourites-edit').attr('href', _spPageContextInfo.webServerRelativeUrl + '/Lists/RbFavourites');
         $('#favourites-loading').fadeOut(500, function() {
            $('.favourites-inner').fadeIn();
         }).remove();
      }
   }();

   $(corpcomms.favourites.start);

})(jQuery);