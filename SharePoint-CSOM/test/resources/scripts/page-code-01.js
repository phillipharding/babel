(function($,window) { 
	var canContinue = true; 
	function pulse() {
		$('#DeltaPlaceHolderPageTitleInTitleArea').effect('highlight').effect('highlight',{color: '#FF00FF'});
		if (canContinue) setTimeout(pulse, 2000);
	}
	$(function() {
		setTimeout(pulse, 2000);
		setTimeout(function() {canContinue = false;}, 20000);
	});
})(jQuery, window);
