(function($) {
"use strict";

	$(function() {
		JSRequest.EnsureSetup();
		/*
		$("ul#tabs li").click(function(e) {
			if (!$(this).hasClass("active")) {
				var tabNum = $(this).index();
				var nthChild = tabNum + 1;
				$("ul#tabs li.active").removeClass("active");
				$(this).addClass("active");
				$("ul#tab li.active").removeClass("active");
				$("ul#tab li:nth-child(" + nthChild + ")").addClass("active");
			}
		});
		*/

		/* init SIDR for mobile search */
//		$(window).resize(function() {
//			$.sidr('close', 'sidr-search');
//		});
		
//		$('#mobile-search').sidr({
//			name: 'sidr-search',
//			source: '#mobile-header-search-box',
//			side: 'right'
//		});
//		var searchQuery = JSRequest.QueryString["k"] || "";
//		$('#sidr-id-search-input-box').val(searchQuery);
/*		$('#sidr-id-search-input-box').on('keypress', function(event) {
			EnsureScriptFunc('Search.ClientControls.js', 'Srch.U', function() {
				if (Srch.U.isEnterKey(String.fromCharCode(event.keyCode))) {
					var searchTerm = $('#sidr-id-search-input-box').val();
					searchTerm += String.format("site:", encodeURIComponent(_spPageContextInfo.webAbsoluteUrl));

					$find('ctl00_searchInputBox_csr').search(searchTerm);
					$.sidr('close', 'sidr-search');
					return Srch.U.cancelEvent(event);
				}
			});
		});*/
		$('#mobile-search').click(function(e) {
			e.preventDefault();
			$(this).toggleClass('active');
			$('#mobile-header-search-box').toggleClass('active');
			/*
			EnsureScriptFunc('Search.ClientControls.js', 'Srch.U', function() {
				var searchTerm = $('#sidr-id-search-input-box').val();
				searchTerm += String.format("site:", encodeURIComponent(_spPageContextInfo.webAbsoluteUrl));
				$find('ctl00_searchInputBox_csr').search(searchTerm);
				$.sidr('close', 'sidr-search');
			});
			*/
		});
		/**/

		/* init SIDR for the megamenu */
		$(window).resize(function() {
			$.sidr('close', 'sidr-existing-content');
		});
		
		$('#mobile-nav').sidr({
			name: 'sidr-existing-content',
			source: '#main-menu',
			onOpen: function() {
				$('#mobile-nav').addClass('active');
				$('#mobile-search').removeClass('active');
				$('#mobile-header-search-box').removeClass('active');
			},
			onClose: function() {
				$('#mobile-nav').removeClass('active');
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

	});

})(jQuery);