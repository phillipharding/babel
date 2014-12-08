(function($) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};

	RB.Masterpage.Userprofile = function() {
		var
			_module = {
				EnsureSetup: ensureSetup,
				Properties: []
			};
		return _module;

		function getData() {
			var 
				p = new $.Deferred(),
				req = {
					type: 'GET',
					url: "/_api/SP.UserProfiles.PeopleManager/GetMyProperties",
					headers: { ACCEPT: 'application/json;odata=minimalmetadata' }
				};
			$.ajax(req)
				.done(function (response, textStatus, xhrObj) {
					var data = response;
					_module.Properties = [];
					_module.Properties['AccountName'] = data.AccountName || "";
					_module.Properties['DisplayName'] = data.DisplayName || "";
					_module.Properties['Email'] = data.Email || "";
					_module.Properties['IsFollowed'] = data.IsFollowed || false;
					_module.Properties['LatestPost'] = data.LatestPost || "";
					_module.Properties['OneDriveUrl'] = data.PersonalUrl || "";
					_module.Properties['UserProfilePictureUrl'] = data.PictureUrl || "";
					_module.Properties['UserProfileUrl'] = data.UserUrl || "";
					for (var i = data.UserProfileProperties.length - 1; i >= 0; i--) {
						var d = data.UserProfileProperties[i];
						if (!d || !d.Key || !d.Key.length) continue;
						_module.Properties[d.Key] = d.Value || '';
					};
					p.resolve(_module.Properties);
				})
				.fail(function(xhrObj, textStatus, err) {
					var
						e = JSON.parse(xhrObj.responseText),
						err = e.error || e["odata.error"],
						m = '<div style="color:red;font-family:Calibri;font-size:1.2em;">Exception<br/>&raquo; ' +
							((err && err.message && err.message.value) ? err.message.value : (xhrObj.status + ' ' + xhrObj.statusText))
							+' <br/>&raquo; '+r.url+'</div>';
					p.reject({ success: false, error: m, uri: endpoint });
				});
			return p.promise();
		}

		function ensureSetup() {
			var p = getData()
						.fail(function(e) {
							if (window.console) window.console.log(e.error);
						});
			return p;
		}
	}();

})(jQuery);
