(function(window,$) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};
RB.Masterpage.Megamenu = function() {
	var
		_module = {
			initialise: initialise,
			render: renderTerms,
			ready: new $.Deferred(),
			tree: {
				term: null,
				children: []
			}
		};
	return _module;

	function initialise(termSetId) {
		SP.SOD.loadMultiple(['sp.js'], function () {
      	if (window.console) { console.log('Megamenu>> SP.js loaded'); }
         SP.SOD.registerSod('sp.taxonomy.js', SP.Utilities.Utility.getLayoutsPageUrl('sp.taxonomy.js'));
         SP.SOD.loadMultiple(['sp.taxonomy.js'], function () {
         	if (window.console) { console.log('Megamenu>> sp.taxonomy.js loaded'); }
				var 
					ctx = SP.ClientContext.get_current(),
					taxonomySession = SP.Taxonomy.TaxonomySession.getTaxonomySession(ctx),
					termStore = taxonomySession.getDefaultSiteCollectionTermStore(),
					termSet = termStore.getTermSet(termSetId),
					terms = termSet.getAllTerms();
				ctx.load(terms);
				ctx.executeQueryAsync(Function.createDelegate(this, function (sender, args) {
					onReceiveTerms(terms);
				}), Function.createDelegate(this, function (sender, args) {
					// handle error
				}));
         });
      });
	}

	function onReceiveTerms(terms) {
	   var
	   	termsEnumerator = terms.getEnumerator(),
	   	tree = {
				term: terms,
				children: []
			};

	   // Loop through each term
	   while (termsEnumerator.moveNext()) {
	       var currentTerm = termsEnumerator.get_current();
	       var currentTermPath = currentTerm.get_pathOfTerm().replace('_','').split(';');
	       var children = tree.children;
	       if (window.console) { console.log('Megamenu>> '+currentTermPath); }

	       // Loop through each part of the path
	       for (var i = 0; i < currentTermPath.length; i++) {
	           var foundNode = false;
	           for (var j = 0; j < children.length; j++) {
	               if (children[j].name === currentTermPath[i]) {
	                   foundNode = true;
	                   break;
	               }
	           }
	           // Select the node, otherwise create a new one
	           var term = foundNode ? children[j] : { name: currentTermPath[i], children: [] };
	           // If we're a child element, add the term properties
	           if (i === currentTermPath.length - 1) {
	               term.term = currentTerm;
	               term.title = currentTerm.get_name();
	               term.guid = currentTerm.get_id().toString();
	           }
	           // If the node did exist, let's look there next iteration
	           if (foundNode) {
	               children = term.children;
	           }
	           // If the segment of path does not exist, create it
	           else {
	               children.push(term);
	              // Reset the children pointer to add there next iteration
	               if (i !== currentTermPath.length - 1) {
	                   children = term.children;
	               }
	           }
	       }
	   }

	   _module.tree = sortTermsFromTree(tree);
	   _module.ready.resolve(_module);
	}

	function sortTermsFromTree(tree) {
     if (tree.children.length && tree.term.get_customSortOrder) {
         var sortOrder = null;

         if (tree.term.get_customSortOrder()) {
             sortOrder = tree.term.get_customSortOrder();
         }

         // If not null, the custom sort order is a string of GUIDs, delimited by a :
         if (sortOrder) {
             sortOrder = sortOrder.split(':');

             tree.children.sort(function (a, b) {
                 var indexA = sortOrder.indexOf(a.guid);
                 var indexB = sortOrder.indexOf(b.guid);

                 if (indexA > indexB) {
                     return 1;
                 } else if (indexA < indexB) {
                     return -1;
                 }

                 return 0;
             });
         }
         // If null, terms are just sorted alphabetically
         else {
             tree.children.sort(function (a, b) {
                 if (a.title > b.title) {
                     return 1;
                 } else if (a.title < b.title) {
                     return -1;
                 }

                 return 0;
             });
         }
     }

     for (var i = 0; i < tree.children.length; i++) {
         tree.children[i] = sortTermsFromTree(tree.children[i]);
     }

     return tree;
	}

	function renderTerms(tree) {

	}

};


$(function() {
	var mm = new RB.Masterpage.Megamenu();
	mm.initialise('966c85b8-5344-4350-a22b-79335e3906c7');
	mm.ready.done(function(m) {
		if (window.console) { console.log('Megamenu>> ready to render!!'); }
		m.render();
	});
});

})(window,jQuery);
