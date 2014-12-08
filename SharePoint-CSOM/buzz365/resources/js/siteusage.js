(function($) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};

	RB.Masterpage.Siteusage = function() {
		var
			_callout = null,
			_module = {
				EnsureSetup: ensureSetup,
				Acceptance: doAcceptance,
				Close: closeCallout,
				IAgree: IAgree,
				Information: '<h1>NO SITEUSAGE INFORMATION IS AVAILABLE</h1>',
				Timestamp: new Date()
			};
		return _module;

		function closeCallout() {
			if (_callout) _callout.close(true);
			_callout = null;
		}
		function getData() {
			var
				p = new $.Deferred(), 
				req = {
					type: 'GET',
					url: String.format("/_api/web/lists/getbytitle('Site Terms')/items?$select=Modified,Body&$top=1&$orderby=Title desc,Modified desc&$filter=(Title eq 'General-Site-Terms' or Title eq 'General-Site-Terms-{0}')", _spPageContextInfo.currentUICultureName),
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
				_module.Information = data[0].Body;
				_module.Timestamp = new Date(data[0].Modified);

				/* setup callout */
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
					calloutOptions.content = String.format("{0}", _module.Information);
					_callout = CalloutManager.createNewIfNecessary(calloutOptions);
	    		});
			}
		}
		function IAgree() {

			SP.UI.ModalDialog.commonModalDialogClose(SP.UI.DialogResult.OK, 'User Accepted');
		}
		function doAcceptance() {
			/* check that the Userprofile type has been initialised */
			if (!RB.Masterpage.IsValidType('RB.Masterpage.Userprofile.EnsureSetup')) return;
			var sudProperty = RB.Masterpage.Userprofile.Properties["Buzz-SiteUsageDisclaimer"];
			if (typeof(sudProperty) === 'undefined') return;
			/* has user 'signed' disclaimer, if so bail */
			if (sudProperty && sudProperty.length) {
				var
					sudPropBits = sudProperty.split('|'),
					sudTimestamp = new Date(sudPropBits && sudPropBits.length > 0 ? sudPropBits[0] : '1900-01-01T00:00:00.000Z');
				if (_module.Timestamp.getTime() <= sudTimestamp.getTime()) return;
			}

			/* show the disclaimer dialog */
			var html = ["<div class='siteusage-dialog'>"];
				html.push(_module.Information);
				html.push("<div class='footer'>");
					html.push("<span><i class='fa fa-info-circle fa-lg'></i>&nbsp;Unless you agree to the terms described on this page and click the 'I Agree' button, you will not be able to continue using this site.</span>");
					html.push("<button onclick='RB.Masterpage.Siteusage.IAgree();return false;'><i class='fa fa-check fa-lg'></i>&nbsp;I Agree</button>");
				html.push("</div>");
			html.push('</div>');

			var $sud = $(html.join('')).get(0);
			var options = {
				html: $sud,
				title: "Site Usage Terms and Conditions",
				allowMaximize: false,
				showClose: false,
				autoSize: true,
				dialogReturnValueCallback: function(dialogResult, returnValue) {
				}
			};
			if (window.console) window.console.log('>>about to show SUD dialog...');
			SP.SOD.execute('SP.UI.Dialog.js', 'SP.UI.ModalDialog.showModalDialog', options);
		}

		function ensureSetup() {
			var p = getData()
						.then(setupUI)
						.fail(function(e) {
							if (window.console) window.console.log(e.error);
						});
			return p;
		}
	}();

})(jQuery);
