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
		});
		
		$('#mobile-nav').sidr({
			name: 'sidr-existing-content',
			source: '#main-menu',
			onOpen: function() {
				//$('#mobile-nav').addClass('active');
				mobileSearch(false);
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

	});

})(jQuery);