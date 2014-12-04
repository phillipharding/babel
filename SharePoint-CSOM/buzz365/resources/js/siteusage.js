(function($) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};

	RB.Masterpage.Siteusage = function() {
		var
			_callout = null,
			_siteusageInformation = '<h1>NO SITEUSAGE INFORMATION FOUND</h1>',
			_module = {
				EnsureSetup: ensureSetup,
				Close: closeCallout
			};
		return _module;

		function closeCallout() {
			if (_callout) _callout.close(true);
			_callout = null;
		}
		function getData() {
			var bod = new Date();
			bod.setHours(0);
			bod.setMinutes(0);
			bod.setSeconds(0);

			var
				p = new $.Deferred(), 
				req = {
					type: 'GET',
					url: String.format("/_api/web/lists/getbytitle('Site Terms')/items?$select=Expires,Body&$top=1&$orderby=Title desc,Expires asc&$filter=(Title eq 'General-Site-Terms' or Title eq 'General-Site-Terms-{1}') and (Expires eq null or Expires ge datetime'{0}')", bod.toISOString(), _spPageContextInfo.currentUICultureName),
					headers: { ACCEPT: 'application/json;odata=minimalmetadata' }
				};
			$.ajax(req)
				.done(function (response, textStatus, xhrObj) {
					var data = (response.value || response.d.results || response.d);
					p.resolve(data);
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
		function setupUI(data) {
			if (data && data.length && data[0].Body && data[0].Body.length) {
				_siteusageInformation = data[0].Body;

				/* setup custom callout */
				var $btn = $('#rb-siteusage');
				$btn
					.removeClass('disabled')
					.attr('title', 'display the site usage terms and conditions');
				
				SP.SOD.executeFunc("callout.js", "Callout", function () {
					var $launchpoint = $btn.find('a').get(0);
					var callout = CalloutManager.getFromLaunchPointIfExists($launchpoint);
					if (callout) callout.close(true);

					var calloutOptions = new CalloutOptions();
					calloutOptions.ID = 'rbcom-siteusage';
					calloutOptions.launchPoint = $launchpoint;
					calloutOptions.title = 'Site Usage Terms and Conditions';
					calloutOptions.beakOrientation = 'topBottom';
					calloutOptions.openOptions = { event: "click", closeCalloutOnBlur: true };
					calloutOptions.content = String.format("{0}", data[0].Body);
					_callout = CalloutManager.createNewIfNecessary(calloutOptions);
	    		});
			}
		}

		function ensureSetup() {
			getData().then(setupUI)
				.fail(function(e) {
					if (window.console) window.console.log(e.error);
				});
		}
	}();

})(jQuery);
