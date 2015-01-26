(function($) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};

	RB.Masterpage.Userprofile = function() {
		var
			_p = new $.Deferred(),
			_module = {
				EnsureSetup: ensureSetup,
				SetProperty: setProfileProperty,
				Properties: []
			};
		return _module;

		function getMyPropertyData() {
			var 
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
					_p.resolve(_module.Properties);
				})
				.fail(function(xhrObj, textStatus, err) {
					var
						e = JSON.parse(xhrObj.responseText),
						err = e.error || e["odata.error"],
						m = '<div style="color:red;font-family:Calibri;font-size:1.2em;">Exception<br/>&raquo; ' +
							((err && err.message && err.message.value) ? err.message.value : (xhrObj.status + ' ' + xhrObj.statusText))
							+' <br/>&raquo; '+r.url+'</div>';
					_p.reject({ success: false, error: m, uri: endpoint });
				});
			return _p.promise();
		}

		/**
			As at 09/12/2014 setting User Profile Property values with JSOM or REST is not supported, it is only supported via CSOM (C#), 
			alternatively we can use the SPServices user profile web service, which is deprecated.
			
			userId: 	The format is "domain\userId" for on-prem and "i:0#.f|membership|<federated ID>"" for SharePoint Online.
						SPO format e.g. i:0#.f|membership|phil.harding@platinumdogsconsulting.onmicrosoft.com
		**/
		function setProfileProperty(propertyName, propertyValue, userId) {
			if (typeof(userId) === 'undefined' || !userId || !userId.length) userId = _module.Properties['AccountName']; /* default to [Me] */

			var p = new $.Deferred();
			RB.Masterpage.LoadSPServices()
				.done(function(r) {
				/* SPServices is loaded */
				RB.Masterpage.Log('RB.Masterpage.Userprofile>> loaded: '+r);

				var propertyData = "<PropertyData>" +
											"<IsPrivacyChanged>false</IsPrivacyChanged>" +
											"<IsValueChanged>true</IsValueChanged>" +
											"<Name>" + propertyName + "</Name>" +
											"<Privacy>NotSet</Privacy>" +
											"<Values><ValueData><Value xsi:type=\"xsd:string\">" + propertyValue + "</Value></ValueData></Values>" +
										"</PropertyData>";
				$().SPServices({
					operation: "ModifyUserPropertyByAccountName",
					async: true,
					webURL: "/",
					accountName: userId,
					newData: propertyData,
					completefunc: function (xData, Status) {
						var 
							response = $(xData.responseXML),
							fc = response.find('faultcode').text();
						if (fc && fc.length) {
							p.reject('Error: ' + response.find('faultstring').text());
						} else {
							p.resolve(true);
						}
					}
				});
			});
			return p.promise();
		}

		function ensureSetup() {
			var p = getMyPropertyData()
						.fail(function(e) {
							RB.Masterpage.Log('RB.Masterpage.Userprofile>> error: '+(e.error));
						});
			return p;
		}
	}();

})(jQuery);

