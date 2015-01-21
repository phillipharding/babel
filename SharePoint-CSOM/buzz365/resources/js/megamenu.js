(function(window,$) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};

RB.Masterpage.Megamenu = function() {
	var
		_module = {
			EnsureSetup: ensureSetup,
			Close: closeSidr
		};
	return _module;

	function closeSidr() {
		$.sidr('close', 'sidr-existing-content');
	}

	function ensureSetup() {
		/* init SIDR for the megamenu */
		
		$('#mobile-nav').sidr({
			name: 'sidr-existing-content',
			source: '#main-menu',
			onOpen: function() {
				$('#mobile-nav').addClass('active');
				if (typeof(CalloutManager)!=='undefined') CalloutManager.closeAll();
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

	}
}();

})(window, jQuery);

