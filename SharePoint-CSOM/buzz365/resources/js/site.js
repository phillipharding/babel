(function($) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};

	RB.Masterpage.Siteusage = function() {
		var
			_callout = null,
			_siteusageInformation = '<h1>NO SITEUSAGE INFORMATION FOUND</h1>',
			_module = {
				initialise: initialise,
				close: closeCallout
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
					url: String.format("/_api/web/lists/getbytitle('Site Terms')/items?$select=Expires,Body&$top=1&$orderby=Expires asc&$filter=Title eq 'General-Site-Terms' and (Expires eq null or Expires ge datetime'{0}')", bod.toISOString()),
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

		function initialise() {
			getData().then(setupUI)
				.fail(function(e) {
					if (window.console) window.console.log(e.error);
				});
		}
	}();


	function mobileSearch(turnOn) {
		if (typeof(turnOn) === 'undefined') {
			turnOn = !($('#mobile-search').hasClass('active'));
		}

		if (turnOn) {
			$('#mobile-search').addClass('active');
			$('#mobile-header-search-box').addClass('active');
		} else {
			$('#mobile-search').removeClass('active');
			$('#mobile-header-search-box').removeClass('active');
		}
	}

	$(function() {
		JSRequest.EnsureSetup();

		/* init mobile search button */
		$('#mobile-search').click(function(e) {
			e.preventDefault();
			mobileSearch();
		});
		/**/

		/* init SIDR for the megamenu */
		$(window).resize(function() {
			$.sidr('close', 'sidr-existing-content');
			mobileSearch(false);
			CalloutManager.closeAll();
		});
		
		$('#mobile-nav').sidr({
			name: 'sidr-existing-content',
			source: '#main-menu',
			onOpen: function() {
				//$('#mobile-nav').addClass('active');
				mobileSearch(false);
				CalloutManager.closeAll();
			},
			onClose: function() {
				//$('#mobile-nav').removeClass('active');
			}
		});
		
		/* Toggle Off Canvas Menu */
		$('.sidr-class-nav-column ul').hide();
		$('.sidr-inner h3').click(function(e) {
			e.preventDefault();
			var ullist = $(this).parent().children('ul:first');
			if (ullist.is(':visible')) {
				ullist.hide('5000');
			} else {
				ullist.show('5000');
			}
		});
		/**/

		/* init site usage terms and conditions */
		RB.Masterpage.Siteusage.initialise();
		/**/

	});

})(jQuery);