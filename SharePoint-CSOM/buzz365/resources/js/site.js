(function(window,$) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};
RB.Masterpage.IsValidType = function (typeName) {
	if (!typeName || !typeName.length) return true;
	var 
		bits = typeName.split('.'),
		r = bits.reduce(function(p,c) {
					return (typeof p == "undefined") ? p : p[c];
				}, window);
	return typeof r !== 'undefined';
}

RB.Masterpage.LoadResourceFromTenantRoot = function(url, afterUi) {
	var
		tenantUrl = _spPageContextInfo.siteAbsoluteUrl.match(/(http[s]?:\/\/[^\/]*)/gi),
		absoluteUrl = String.format("{0}/{1}", tenantUrl.replace(/\/$/,''), url.replace(/^\//,''));
	return RB.Masterpage.LoadResource(absoluteUrl, afterUi);
}
RB.Masterpage.LoadResourceFromSiteCollection = function(url, afterUi) {
	var relativeUrl = String.format("{0}/{1}", _spPageContextInfo.siteServerRelativeUrl.replace(/\/$/,''), url.replace(/^\//,''));
	return RB.Masterpage.LoadResource(relativeUrl, afterUi);
}
RB.Masterpage.LoadResource = function(url, afterUi) {
   var
   	p = new $.Deferred(),
      resource = null,
      headOrBody = document.getElementsByTagName(typeof afterUi !== 'undefined' && afterUi ? "body" : "head")[0];
   if (url.match(/.js$/gi)) {
      resource = document.createElement("script");
      resource.type = "text/javascript";

      if (resource.readyState) { // IE
         resource.onreadystatechange = function() {
            if (resource.readyState == "loaded" || resource.readyState == "complete") {
               resource.onreadystatechange = null;
               p.resolve(url);
            }
         };
      } else { // Others
         resource.onload = function() {
            resource.onload = null;
            p.resolve(url);
         };
      }
      resource.src = url;
   } else if (url.match(/.css$/gi)) {
      resource = document.createElement('link');
      resource.rel = 'stylesheet';
      resource.type = "text/css";
      resource.href = url;
      p.resolve(url);
   }
   if (resource) {
      headOrBody.appendChild(resource);
   }
   return p.promise();
}

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
		RB.Masterpage.LoadResourceFromSiteCollection("_catalogs/masterpage/Buzz365/js/megamenu.js")
			.done(function() {
				if (window.console) window.console.log(">>MEGAMENU.JS loaded");
				
				$(window).resize(function() {
					RB.Masterpage.Megamenu.Close();
					if (typeof(CalloutManager)!=='undefined') CalloutManager.closeAll();
				});

				RB.Masterpage.Megamenu.EnsureSetup();
			});

		/* synchronised loading/initialisation of the siteusage and userprofile modules */
		var
			upsuModulesInitialised = new $.Deferred(), 
			upsuModulesLoaded = [
				RB.Masterpage.LoadResourceFromSiteCollection("_catalogs/masterpage/Buzz365/js/siteusage.js"),
				RB.Masterpage.LoadResourceFromSiteCollection("_catalogs/masterpage/Buzz365/js/userprofile.js")
			];
		$.when.apply($, upsuModulesLoaded)
			.done(function() {
				if (window.console) window.console.log(">>USERPROFILE.JS and SITEUSAGE.JS loaded");
				var waitCount = 0;
				function deferAndWaitForModuleExecution() {
					/* while the scripts have been loaded they '**may**' not have executed yet, so we 
						may have to wait for this to happen before we can call the module init functions.
					*/
					if (!RB.Masterpage.IsValidType('RB.Masterpage.Siteusage.EnsureSetup') || !RB.Masterpage.IsValidType('RB.Masterpage.Userprofile.EnsureSetup')) {
						waitCount++;
						if (waitCount > 10) 
							upsuModulesInitialised.reject(); /* give up after waiting for execution for 2 seconds */
						else {
							if (window.console) window.console.log(">>deferAndWaitForModuleExecution("+waitCount+") for USERPROFILE.JS and SITEUSAGE.JS initialisation");
							setTimeout(deferAndWaitForModuleExecution, 200);
						}
						return;
					}
					var moduleInits = [
						RB.Masterpage.Siteusage.EnsureSetup(),
						RB.Masterpage.Userprofile.EnsureSetup()
					];
					$.when.apply($, moduleInits)
						.done(function() {
							upsuModulesInitialised.resolve();
						});
				}
				deferAndWaitForModuleExecution();
			});
		upsuModulesInitialised
			.done(function() {
				if (window.console) window.console.log(">>USERPROFILE.JS and SITEUSAGE.JS initialised");
				RB.Masterpage.Siteusage.Acceptance();
			});
		/**/

		/* initialise the Focus on Content feature overload */
		SP.SOD.executeOrDelayUntilScriptLoaded(function() {
			if (window.console) { window.console.log('site.js() CORE.JS loaded'); }
			RB.Masterpage.OldSetFullScreenMode = window.SetFullScreenMode;
			RB.Masterpage.OriginalContentBoxCss = document.getElementById('contentBox-x').getAttribute('class');

			window.SetFullScreenMode = function RB_Masterpage$SetFullScreenMode(fEnableFullScreenMode) {
				if (typeof fEnableFullScreenMode !== 'undefined') {
					RB.Masterpage.OldSetFullScreenMode(fEnableFullScreenMode);
				}
				var bIsFullScreenMode = window.HasCssClass(document.body, "ms-fullscreenmode");
				if (bIsFullScreenMode) {
					$('#sideNavBox-x').hide();
					$('#contentBox-x').attr('class', 'pure-u-1');
				} else {
					$('#contentBox-x').attr('class', RB.Masterpage.OriginalContentBoxCss);
					$('#sideNavBox-x').show();
				}		
			}
			window.SetFullScreenMode();
      }, 'core.js');

	});

})(window,jQuery);


