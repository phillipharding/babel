(function($) {
"use strict";

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

		/* setup mobile search button */
		$('#mobile-search').click(function(e) {
			e.preventDefault();
			mobileSearch();
		});
		/**/

		/* load the megamenu module */
		$.getScript(String.format("{0}/_catalogs/masterpage/Buzz365/js/megamenu.js", _spPageContextInfo.siteServerRelativeUrl.replace(/\/$/,'')))
			.done(function() {
				if (window.console) window.console.log(">>Megamenu.js loaded");
				
				$(window).resize(function() {
					RB.Masterpage.Megamenu.Close();
					if (typeof(CalloutManager)!=='undefined') CalloutManager.closeAll();
				});

				/* init megamenu */
				RB.Masterpage.Megamenu.EnsureSetup();
				/**/
			});
		/* load the siteusage module */
		$.getScript(String.format("{0}/_catalogs/masterpage/Buzz365/js/siteusage.js", _spPageContextInfo.siteServerRelativeUrl.replace(/\/$/,'')))
			.done(function() {
				if (window.console) window.console.log(">>siteusage.js loaded");
				/* init site usage terms and conditions */
				RB.Masterpage.Siteusage.EnsureSetup();
				/**/
			});

	});

})(jQuery);