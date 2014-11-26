(function($) {
"use strict";

$(function() {
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
	$(window).resize(function() {
/*		$.sidr('close', 'sidr-existing-content'); */
	});
/*
	$('#mobile-nav').sidr({
		name: 'sidr-existing-content',
		source: '#main-menu'
	});
*/
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
});

})(jQuery);
