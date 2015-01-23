(function(window,$) {
"use strict";

function TreeRender(taxonomyDs) {
	this.taxonomyDs = taxonomyDs && typeof(taxonomyDs) === 'object' ? taxonomyDs : null;
	return { renderAsString: renderMenuAsString.bind(this) }

	function renderMenuAsString(datasourceNodes, $domContainer) {
		var markup = ["<nav id='"+this.taxonomyDs.module.Tag+"'><ul>"];
		for(var i = 0; i < datasourceNodes.length; i++) {
			markup.push(renderNode(datasourceNodes[i], 0));
		}
		markup.push('</ul></nav>');
		return markup.join('');
	}

	function renderNode(node, depth) {
		var markup = [];
		node.title = node.title.replace(/[_]*$/gi, '').replace(/ and /gi, ' & ');
		if (window.console) { window.console.log('TreeRender>> render node: '+node.title+' <<'); }
		switch (node.nodeType) {
			default: {
				markup.push(String.format("<li data-depth='{1}'><h3>{0}</h3>", node.title, depth));
				if (node.childNodes && node.childNodes.length) {
					markup.push(String.format("<ul style='margin-left:{0}px;'>", 25));
					/* has child Links, iterate and render each link */
					for(var lx = 0; lx < node.childNodes.length; lx++) {
						markup.push(renderNode(node.childNodes[lx], depth+1));
					}
					markup.push("</ul>");
				}
				markup.push("</li>");
				break;
			}
		}
		return markup.join('');
	}
}

$(function() {
	var
		durStartTime = new Date(),
		$container = $('#tree').css({opacity:'.2'});

	function OnDatastoreReady(taxonomyDs) {
		if (window.console) { console.log('OnDatastoreReady>> TaxonomyDatastore ['+taxonomyDs.Id+'] is ready'); }
		taxonomyDs.module.render($container, new TreeRender(taxonomyDs));
		$container.css({opacity:'1'});

		var ellapsed = ((new Date()).getTime()) - (durStartTime.getTime());
		if (window.console) { console.log('OnDatastoreReady>> TaxonomyDatastore ['+taxonomyDs.Id+'] ellapsed time: ' + (ellapsed)+'ms'); }
	}

	var
		termsetId = '1db4f02a-d182-499e-8f3b-dc32bb00e253', 
		cacheDisabled = -1,
		cacheDurationHours = 24,
		taxDs = new RB.Masterpage.TaxonomyDatastore(termsetId, RB.Storage.session, cacheDurationHours);
	taxDs.initialise();
	taxDs.isInitialised.done(OnDatastoreReady);
});

})(window,jQuery);
