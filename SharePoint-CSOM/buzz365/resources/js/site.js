(function(window,$) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = function() {
	var
		_bxs = null,
		_jqui = null,
		_wap = null,
		_kom = null,
		_sps = null,
		_module = {
			UpSuModulesInitialised: new $.Deferred(),
			Tenant: '',
			Version: '',
			Lcid: 1033,
			ViewportHeight: 0,
			ViewportWidth: 0,
			LoadBxSlider: RB$Masterpage$LoadBxSlider,
			LoadJQueryUI: RB$Masterpage$LoadJQueryUI,
			LoadKnockout: RB$Masterpage$LoadKnockout,
			LoadSPServices: RB$Masterpage$LoadSPServices,
			IsValidType: RB$Masterpage$IsValidType,
			Log: RB$Masterpage$Log,
			ClearLocalStorage: RB$Masterpage$ClearLocalStorage,
			LoadResourceFromTenantRoot: RB$Masterpage$LoadResourceFromTenantRoot,
			LoadResourceFromSiteCollection: RB$Masterpage$LoadResourceFromSiteCollection,
			LoadAllResources: RB$Masterpage$LoadAllResources,
			LoadResource: RB$Masterpage$LoadResource,
			LoadWebproperties: RB$Masterpage$Webproperties,
			Initialise: RB$Masterpage$Initialise,
			PageInEditMode: RB$Masterpage$PageInEditMode
		};
	return _module;

	function RB$Masterpage$PageInEditMode() {
		var inEditMode = null;
		if (document.forms[MSOWebPartPageFormName].MSOLayout_InDesignMode) {
			inEditMode = document.forms[MSOWebPartPageFormName].MSOLayout_InDesignMode.value;
		}
		var wikiInEditMode = null;
		if (document.forms[MSOWebPartPageFormName]._wikiPageMode) {
			wikiInEditMode = document.forms[MSOWebPartPageFormName]._wikiPageMode.value;
		}
		if (!inEditMode && !wikiInEditMode)
			return false;

		return inEditMode == "1" || wikiInEditMode == "Edit";
	}

	function RB$Masterpage$Initialise() {
		var at = $('body').attr('class');
		if (at && at.length) {
			if (at.match(/buzz365-responsive-v1/gi)) _module.Version = 'v1.1.0.0';
			else if (at.match(/buzz365-responsive-v2/gi)) _module.Version = 'v1.2.0.0';
		}
		if (RB$Masterpage$IsValidType("g_wsaLCID")) _module.Lcid = g_wsaLCID;
		if (RB$Masterpage$IsValidType("g_viewportHeight")) _module.ViewportHeight = g_viewportHeight;
		if (RB$Masterpage$IsValidType("g_viewportWidth")) _module.ViewportWidth = g_viewportWidth;

		var tenant = window.location.href.match(/^http[s]?:\/\/[^\/]*/gi);
		if (tenant && tenant.length) {
			_module.Tenant = tenant[0].replace(/^http[s]?:\/\//gi,'');
		}
	}

	function RB$Masterpage$Webproperties(clearCache) {
		if (_wap && (typeof(clearCache) === 'undefined' || !clearCache)) return _wap;
		_wap = new $.Deferred();
		var req = {
			type: 'GET',
			url: String.format("{0}/_api/web/AllProperties", _spPageContextInfo.webServerRelativeUrl),
			headers: { ACCEPT: 'application/json;odata=minimalmetadata' }
		};
		$.ajax(req)
			.done(function (response, textStatus, xhrObj) {
				var newData = {};
				for(var k in response) {
					if (k.match(/^odata./g)) continue;
					var k1 = k.replace(/_x005f_/gi, '_').replace(/_x0020_/gi, ' ').replace(/_x002d_/gi, '-');
					newData[k1] = response[k];
				}
				_wap.resolve(newData);
			})
			.fail(function(xhrObj, textStatus, err) {
				var
					e = JSON.parse(xhrObj.responseText),
					err = e.error || e["odata.error"],
					m = '<div style="color:red;font-family:Calibri;font-size:1.2em;">Exception<br/>&raquo; ' +
						((err && err.message && err.message.value) ? err.message.value : (xhrObj.status + ' ' + xhrObj.statusText))
						+' <br/>&raquo; '+r.url+'</div>';
				_wap.reject({ success: false, error: m, uri: endpoint });
			});
		
		/** E.g.

				RB.Masterpage.LoadWebproperties()
					.done(function(props) {
						for(var k in props) {
							console.log('property: key='+k+', value='+props[k]);
						}
					});
		**/
		return _wap;
	}

	function RB$Masterpage$LoadJQueryUI() {
		if (!_jqui) {
			var deps = [
				RB$Masterpage$LoadResourceFromTenantRoot("_catalogs/masterpage/Buzz365/js/jquery-ui-1.11.2.min.js"),
				RB$Masterpage$LoadResourceFromTenantRoot("_catalogs/masterpage/Buzz365/css/flick/jquery-ui-1.11.2.min.css")
			];
			_jqui = $.when.apply($, deps)
						.done(function(jquijs, jquicss) {
							if (window.console) {
								window.console.log('Masterpage>> RB$Masterpage$LoadJQueryUI ['+jquijs+']');
								window.console.log('Masterpage>> RB$Masterpage$LoadJQueryUI ['+jquicss+']');
							}
						});
		}
		/** E.g
				RB.Masterpage.LoadJQueryUI()
					.done(function(jquijs, jquicss) {
						console.log('loaded jquery');
					});
		**/
		return _jqui;
	}

	function RB$Masterpage$LoadBxSlider() {
		if (!_bxs) {
			var deps = [
				RB$Masterpage$LoadResourceFromTenantRoot("_catalogs/masterpage/Buzz365/js/jquery.bxslider.min.js"),
				RB$Masterpage$LoadResourceFromTenantRoot("_catalogs/masterpage/Buzz365/css/jquery.bxslider.css")
			];
			_bxs = $.when.apply($, deps)
						.done(function(js, css) {
							if (window.console) {
								window.console.log('Masterpage>> RB$Masterpage$LoadBxSlider ['+js+']');
								window.console.log('Masterpage>> RB$Masterpage$LoadBxSlider ['+css+']');
							}
						});
		}
		/** E.g
				RB.Masterpage.LoadBxSlider()
					.done(function(js, css) {
						console.log('loaded bxSlider');
					});
		**/
		return _bxs;
	}

	function RB$Masterpage$LoadKnockout() {
		if (!_kom) {
			_kom = RB$Masterpage$LoadResourceFromTenantRoot("_catalogs/masterpage/Buzz365/js/knockout-3.2.0.js");
		}
		/** E.g
				RB.Masterpage.LoadKnockout()
					.done(function(r) {
						console.log('loaded: '+r);
					});
		**/
		return _kom;
	}

	function RB$Masterpage$LoadSPServices() {
		if (!_sps) {
			_sps = RB$Masterpage$LoadResourceFromTenantRoot("_catalogs/masterpage/Buzz365/js/jquery.SPServices-2014.01.min.js");
		}
		return _sps;
	}

	function RB$Masterpage$IsValidType(typeName) {
		if (!typeName || !typeName.length) return true;
		var 
			bits = typeName.split('.'),
			r = bits.reduce(function(p,c) {
						return (typeof p == "undefined") ? p : p[c];
					}, window);
		return typeof r !== 'undefined';
	}

	function RB$Masterpage$ClearLocalStorage(message) {
		try {
			for(var key in localStorage) {
				if (key.match(/^RB\$/gi)) {
					localStorage.removeItem(key);
				}
			}
		} catch (e) {
		}
	}

	function RB$Masterpage$Log(message) {
		if (message && message.length && window.console && window.console.log) {
			window.console.log('[['+(new Date().format('HH:mm:ss.fff'))+']] '+message);
		}
	}

	function RB$Masterpage$LoadResourceFromTenantRoot(url, afterUi) {
		var
			m = _spPageContextInfo.siteAbsoluteUrl.match(/(http[s]?:\/\/[^\/]*)/gi),
			tenantUrl = m && m.length ? m[0] : '',
			absoluteUrl = String.format("{0}/{1}", tenantUrl.replace(/\/$/,''), url.replace(/^\//,''));
		return RB$Masterpage$LoadResource(absoluteUrl, afterUi);
	}
	
	function RB$Masterpage$LoadResourceFromSiteCollection(url, afterUi) {
		var relativeUrl = String.format("{0}/{1}", _spPageContextInfo.siteServerRelativeUrl.replace(/\/$/,''), url.replace(/^\//,''));
		return RB$Masterpage$LoadResource(relativeUrl, afterUi);
	}

	function RB$Masterpage$LoadAllResources(urls, afterUi) {
		var deps = [];
		for(var $i=0; $i < urls.length; $i++) {
			deps.push(RB$Masterpage$LoadResource(urls[$i], afterUi));
		}
		if (!deps.length) return new $.Deferred().reject('no resource urls supplied!').promise();

		var p = $.when.apply($, deps)
					.done(function() {
						if (window.console) {
							for(var $i=0; $i < arguments.length; $i++){
								window.console.log('Masterpage>> RB$Masterpage$LoadAllResources ['+arguments[$i]+']');
							}
						}
					});
		/** E.g
				RB.Masterpage.LoadAllResources('','')
					.done(function(arguments) {
						console.log('loaded resources');
					});
		**/
		return p.promise();
	}

	function RB$Masterpage$LoadResource(url, afterUi) {
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
	      } else { // good browsers
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
	   } else {
	   	p.reject('unsupported resource type, only *.js or *.css are allowed!');
	   }
	   return p.promise();
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
	RB.Masterpage.Initialise();

	/* start: setup mobile search button */
	$('#mobile-search').click(function(e) {
		e.preventDefault();
		mobileSearch();
	});
	/* end: setup mobile search button */

	/* start: initialise the Megamenu */
	if (RB.Masterpage.IsValidType("RB.Masterpage.Megamenu")) {
		if (window.console) {
			RB.Masterpage.Log("Masterpage>> RB.Masterpage.Megamenu,RB.Masterpage.TaxonomyDatastore,RB.Masterpage.LocalStorage (megamenu.js) is loaded");
		}
		
		RB.Masterpage.Megamenu.EnsureSetup();
		$(window).resize(function() {
			RB.Masterpage.Megamenu.Close();
			if (typeof(CalloutManager)!=='undefined') CalloutManager.closeAll();
		});
	} else {
		throw new Error("Masterpage>> RB.Masterpage.Megamenu (megamenu.js) is not loaded!!");
	}
	/* end: initialise the Megamenu */

	/* initialise userprofile module */
	if (RB.Masterpage.IsValidType('RB.Masterpage.Userprofile.EnsureSetup')) {
		RB.Masterpage.Log("Masterpage>> calling RB.Masterpage.Userprofile.EnsureSetup");
		RB.Masterpage.Userprofile.EnsureSetup().done(function() {
			RB.Masterpage.Log("Masterpage>> RB.Masterpage.Userprofile.EnsureSetup has initialised");
			RB.Masterpage.UpSuModulesInitialised.resolve();
		});
	} else {
		throw new Error("Masterpage>> RB.Masterpage.Userprofile.EnsureSetup is undefined!!!");
	}

	/* initialise siteusage module when userprofile module is initialised */
	RB.Masterpage.UpSuModulesInitialised
		.done(function() {
			if (RB.Masterpage.IsValidType('RB.Masterpage.Siteusage.EnsureSetup')) {
				RB.Masterpage.Log("Masterpage>> calling RB.Masterpage.Siteusage.EnsureSetup");
				RB.Masterpage.Siteusage.EnsureSetup().done(function() {
					RB.Masterpage.Log("Masterpage>> RB.Masterpage.Siteusage.EnsureSetup has initialised");
				});
			} else {
				throw new Error("Masterpage>> RB.Masterpage.Siteusage.EnsureSetup is undefined!!!");
			}
		});

	/* initialise the Focus on Content feature overload */
	SP.SOD.executeOrDelayUntilScriptLoaded(function() {
		RB.Masterpage.Log('Masterpage>> core.js loaded, initialise "Focus on Content" feature');
		RB.Masterpage.OldSetFullScreenMode = window.SetFullScreenMode;
		RB.Masterpage.OriginalContentBoxCss = document.getElementById('contentBox-x').getAttribute('class');

		window.SetFullScreenMode = function RB_Masterpage$SetFullScreenMode(fEnableFullScreenMode) {
			if (typeof fEnableFullScreenMode !== 'undefined') {
				RB.Masterpage.OldSetFullScreenMode(fEnableFullScreenMode);
			}
			var bIsFullScreenMode = window.HasCssClass(document.body, "ms-fullscreenmode");
			if (bIsFullScreenMode || (typeof(g_Buzz365NoLeftNav) !== 'undefined')) {
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



