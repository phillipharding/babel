(function(window,$) {
"use strict";

window.RB = window.RB || {};
RB.Masterpage = RB.Masterpage || {};

RB.Masterpage.LocalStorage = function(cacheId, durationSeconds, cacheSlots) {
	var self = this;
	self.cacheId = cacheId;
	self.timestampCacheId = cacheId+'-timestamp';
	self.durationSecs = typeof(durationSeconds) === 'number' ? durationSeconds : -1;
	self.expiresOn = null;
	self.cacheSlots = cacheSlots && (Object.prototype.toString.call(cacheSlots) === '[object Array]') ? cacheSlots : [];

	if (RB.Masterpage.LocalStorage.IsSupported()) {
		var expiryStamp = localStorage.getItem(this.timestampCacheId);
		self.expiresOn = (expiryStamp && expiryStamp.length) ? new Date(parseInt(expiryStamp)+(this.durationSecs*1000)) : null;
	}

	self.isExpired = isExpired.bind(self);
	self.hasValue = hasValue.bind(self);
	self.getValue = getValue.bind(self);
	self.setValue = setValue.bind(self);
	self.remove = remove.bind(self);
	return this;

	function remove(cacheSlot) {
		if (!RB.Masterpage.LocalStorage.IsSupported()) { if (window.console) { window.console.log('!! RB.Masterpage.LocalStorage.IsSupported = FALSE !!'); } return; }

		if (cacheSlot && cacheSlot.length) {
			if (this.cacheSlots.indexOf(cacheSlot) >= 0) {
				localStorage.removeItem(this.cacheId+'-'+cacheSlot);
			}
		} else {
			localStorage.removeItem(this.cacheId);
			for(var i = 0; i < this.cacheSlots.length; i++) {
				localStorage.removeItem(this.cacheId+'-'+this.cacheSlots[i]);
			}
			localStorage.removeItem(this.timestampCacheId);
		}
	}
	function isExpired() {
		if (!RB.Masterpage.LocalStorage.IsSupported()) { if (window.console) { window.console.log('!! RB.Masterpage.LocalStorage.IsSupported = FALSE !!'); } return true; }
		
		var expiryStamp = localStorage.getItem(this.timestampCacheId);
		if (expiryStamp == null || !expiryStamp.length) return true;
		if (this.durationSecs > 0) {
			var
				currentTime = Math.floor((new Date().getTime()) / 1000),
				expiryTime = Math.floor((new Date(parseInt(expiryStamp)).getTime()) / 1000);
			if ((currentTime - expiryTime) > parseInt(this.durationSecs)) {
				return true; /* expired */
			}
			else {
				return false;
			}
		}
		else {
			if (this.durationSecs === 0) return false;	/* never expires */
			return true; /* expired */
		}
	}
	function getValue(cacheSlot) {
		if (!RB.Masterpage.LocalStorage.IsSupported()) { if (window.console) { window.console.log('!! RB.Masterpage.LocalStorage.IsSupported = FALSE !!'); } return null; }

		var value = !cacheSlot || !cacheSlot.length 
							? localStorage.getItem(this.cacheId) 
							: this.cacheSlots.indexOf(cacheSlot) >= 0 ? localStorage.getItem(this.cacheId+'-'+cacheSlot) : null;
		return value;
	}
	function hasValue(cacheSlot) {
		if (!RB.Masterpage.LocalStorage.IsSupported()) { if (window.console) { window.console.log('!! RB.Masterpage.LocalStorage.IsSupported = FALSE !!'); } return null; }

		var value = !cacheSlot || !cacheSlot.length 
							? localStorage.getItem(this.cacheId) 
							: this.cacheSlots.indexOf(cacheSlot) >= 0 ? localStorage.getItem(this.cacheId+'-'+cacheSlot) : null
		return (value && value.length) ? true : false;
	}
	function setValue(newValue, cacheSlot) {
		if (!RB.Masterpage.LocalStorage.IsSupported()) { if (window.console) { window.console.log('!! RB.Masterpage.LocalStorage.IsSupported = FALSE !!'); } return; }

		if (!cacheSlot || !cacheSlot.length) {
			localStorage.setItem(this.cacheId, newValue || '');

			/* setting the value of the primary cache value resets the 'slotted' cache values */
			for(var i = 0; i < this.cacheSlots.length; i++) {
				localStorage.removeItem(this.cacheId+'-'+this.cacheSlots[i]);
			}
		} else {
			/* don't update the expiry stamp for setting a 'slotted' cache value */
			if (this.cacheSlots.indexOf(cacheSlot) >= 0) {
				localStorage.setItem(this.cacheId+'-'+cacheSlot, newValue || '');
			}
			return;
		}
		
		var expires = (new Date().getTime());
		this.expiresOn = new Date(expires+(this.durationSecs*1000));
		localStorage.setItem(this.timestampCacheId, expires);
	}
}
RB.Masterpage.LocalStorage.IsSupported = function() {
	try {
		return 'localStorage' in window && window['localStorage'] !== null;
	} catch (e) {
		return false;
	}
}

RB.Masterpage.TaxonomyDatastore = function(termSetId, cacheDurationHours) {
	if (typeof(cacheDurationHours) === 'undefined') cacheDurationHours = 24*60*60;
	else if (typeof(cacheDurationHours) === 'number' && cacheDurationHours >= 0) cacheDurationHours = cacheDurationHours*60*60;
	else cacheDurationHours = -1;

	var self = this;
	self.Id = termSetId.replace(/-/gi,'');
	self.cache = cacheDurationHours >= 0 
						? new RB.Masterpage.LocalStorage('RB$Masterpage$Megamenu-'+self.Id, cacheDurationHours, ['Markup']) 
						: null;
	self.module = {
		Tag: self.Id,
		getContext: function() { return self; },
		initialise: initialise.bind(self),
		render: renderTerms.bind(self),
		isInitialised: new $.Deferred(),
		nodes: []
	};
	RB.Masterpage.TaxonomyDatastore.Instances = RB.Masterpage.TaxonomyDatastore.Instances || [];
	RB.Masterpage.TaxonomyDatastore.Instances.push(this);
	return self.module;

	function initialise() {
		if (this.cache && !this.cache.isExpired()) {
			if (window.console) { console.log('TaxonomyDatastore>> ['+this.Id+'] datasource being served from cache'); }
			var cached = JSON.parse(this.cache.getValue());
			this.module.Tag = cached.module.Tag;
			this.module.nodes = cached.module.nodes;
			this.module.isInitialised.resolve(this);
			return;
		}
		SP.SOD.loadMultiple(['sp.js'], function () {
      	if (window.console) { console.log('TaxonomyDatastore>> SP.js loaded'); }
         SP.SOD.registerSod('sp.taxonomy.js', SP.Utilities.Utility.getLayoutsPageUrl('sp.taxonomy.js'));
         SP.SOD.loadMultiple(['sp.taxonomy.js'], function () {
         	if (window.console) { console.log('TaxonomyDatastore>> sp.taxonomy.js loaded'); }
				var 
					ctx = SP.ClientContext.get_current(),
					taxonomySession = SP.Taxonomy.TaxonomySession.getTaxonomySession(ctx),
					termStore = taxonomySession.getDefaultSiteCollectionTermStore(),
					termSet = termStore.getTermSet(termSetId),
					terms = termSet.getAllTerms();
				ctx.load(termSet);
				ctx.load(terms);
				ctx.executeQueryAsync(function (sender, args) {
					self.module.Tag = termSet.get_name()+'-'+self.Id
					buildTermNodeTreeFromFlatList.call(self, terms, termSet);
				}, function (sender, args) {
					/* handle error */
					var m = args.get_message();
					throw new Error(String.format("TaxonomyDatastore>> [{1}] error: {0}", m, self.Id));
				});
         });
      });
	}

	function buildTermNodeTreeFromFlatList(terms, termSet) {
		var
	   	termsEnumerator = terms.getEnumerator(),
	   	node = {
				term: terms,
				customSortOrder: termSet && termSet.get_customSortOrder ? termSet.get_customSortOrder() || '' : '',
				childNodes: []
			};

	   /* iterate each term */
	   while (termsEnumerator.moveNext()) {
	   	var 
				currentTerm = termsEnumerator.get_current(),
				currentTermProperties = currentTerm.get_localCustomProperties(),
				currentTermNodeType = currentTermProperties["_Rb_Nav_Type"] || '',
				currentTermPath = currentTerm.get_pathOfTerm().split(';'),
				currentChildNodes = node.childNodes;

			/* iterate each part of the terms path */
			for (var i = 0; i < currentTermPath.length; i++) {
				var foundNode = false;
				/* find this node in the current set of childNodes */
				for (var j = 0; j < currentChildNodes.length; j++) {
					if (currentChildNodes[j].name === currentTermPath[i]) {
						foundNode = true;
						break;
					}
				}
				/* select the current child node, OR,  create a new one */
				var term = foundNode ? currentChildNodes[j] : { name: currentTermPath[i], childNodes: [] };
	           
				/* if we're a child element, add the term properties */
				if (i === currentTermPath.length - 1) {
					term.nodeType = currentTermNodeType;
					term.title = currentTerm.get_name();
					term.termId = currentTerm.get_id().toString();
					term.customSortOrder = currentTerm.get_customSortOrder ? currentTerm.get_customSortOrder() || '' : '';
					term.cssClass = currentTermProperties["_Rb_Nav_CssClass"] || '';
					if (!currentTermNodeType.match(/column/gi)) {
						if (currentTermNodeType === 'Section') {
							if (currentTermProperties["_Sys_Nav_SimpleLinkUrl"]) {
								term.navigateUrl = currentTermProperties["_Sys_Nav_SimpleLinkUrl"] || '';
								term.hoverText = currentTermProperties["_Sys_Nav_HoverText"] || '';
							}
						} else if (currentTermNodeType === 'Root') {
							term.navigateUrl = currentTermProperties["_Sys_Nav_SimpleLinkUrl"] || '';
							term.hoverText = currentTermProperties["_Sys_Nav_HoverText"] || '';
						} else {
							/*term.term = currentTerm;*/
							term.description = currentTerm.get_description() || '';
							term.navigateUrl = currentTermProperties["_Sys_Nav_SimpleLinkUrl"] || '';
							term.hoverText = currentTermProperties["_Sys_Nav_HoverText"] || '';
						}
					}
				}
	           
				/* if the node did exist, look there for the next term path iteration */
				if (foundNode) {
	         	currentChildNodes = term.childNodes;
	         } else {
					/* if the segment of term path does not exist, create it */
	            currentChildNodes.push(term);
	              	
	            /* reset the childNodes pointer to add there for the next term path iteration */
	            if (i !== currentTermPath.length - 1) {
	            	currentChildNodes = term.childNodes;
	            }
	         }
			}
	   }

		var n = applySortOrdering(node);
	   this.module.nodes = n && n.childNodes ? n.childNodes : [];
	   /* cache the built data tree */
	   if (this.cache) {
	   	this.cache.setValue(JSON.stringify(this));
		}
	   /* signal the datasource is initialised */
	   this.module.isInitialised.resolve(this);
	}

	function applySortOrdering(nodeTree) {
		/* check to see if the get_customSortOrder function is defined, if the term is 
			a term collection, then sort the nodes childNodes */
		if (nodeTree.childNodes.length && nodeTree.customSortOrder) {
      	var sortOrder = nodeTree.customSortOrder || '';

         /* if sortOrder is not null, the custom sort order is a string of term id's (guids), delimited by a : */
         if (sortOrder && sortOrder.length) {
         	sortOrder = sortOrder.split(':');
				nodeTree.childNodes.sort(function(a, b) {
            	var
            		indexA = sortOrder.indexOf(a.termId),
            		indexB = sortOrder.indexOf(b.termId);
					if (indexA > indexB) {
               	return 1;
               } else if (indexA < indexB) {
                  return -1;
               }
               return 0;
				});
         } else {
         	/* if sortOrder is null, terms are sorted alphabetically by term title */
            nodeTree.childNodes.sort(function (a, b) {
            	if (a.title > b.title) {
               	return 1;
               } else if (a.title < b.title) {
               	return -1;
               }
               return 0;
            });
         }
		}

		for (var i = 0; i < nodeTree.childNodes.length; i++) {
			nodeTree.childNodes[i] = applySortOrdering(nodeTree.childNodes[i]);
		}
		return nodeTree;
	}

	function renderTerms(domContainer, renderer) {
		if (typeof(domContainer) === 'undefined' || !domContainer) {
			throw new Error('TaxonomyDatastore>> ['+this.Id+'] no domContainer parameter supplied!');
		}
		var isCached = this.cache && this.cache.hasValue('Markup');
		if (window.console) {
			if (isCached) {
				window.console.log('TaxonomyDatastore>> ['+this.Id+'] Markup being served from cache');
			}
			window.console.log('TaxonomyDatastore>> render ['+this.Id+']['+this.module.Tag+'] at '+domContainer);
		}

		var $domContainer = null;
		if (typeof(domContainer) === 'string') {
			$domContainer = $(domContainer);
		} else if (typeof(domContainer) === 'object' && domContainer && domContainer.html) {
			/* assume domContainer is a jQuery object */
			$domContainer = domContainer;
		}

		var markup = isCached ? [this.cache.getValue('Markup')] : [];
		if (!isCached || !markup.length) {
			/* invalid or no cached markup - build it using the supplied renderer */
			isCached = false;
			markup = [];

			if (renderer && (typeof(renderer) === 'object') && renderer.renderAsString && typeof(renderer.renderAsString) === 'function') {
				var m = renderer.renderAsString(this.module.nodes, $domContainer);
				if (m && m.length)
					markup.push(m);
			} else {
				throw new Error("TaxonomyDatastore>> No Renderer supplied, or Renderer supplied does not have a 'renderAsString(...)' method!");
			}
		}

		markup = markup.join('');
		if ($domContainer && markup) {
			$domContainer.html(markup);
		}

		if (!isCached && this.cache && markup && markup.length) {
			this.cache.setValue(markup, 'Markup');
		}
	}
}

function SimpleMenuRender(taxonomyDs) {
	this.taxonomyDs = taxonomyDs && typeof(taxonomyDs) === 'object' ? taxonomyDs : null;
	return { renderAsString: renderMenuAsString.bind(this) }

	function renderMenuAsString(datasourceNodes, $domContainer) {
		var markup = ["<h1 id='"+this.taxonomyDs.module.Tag+"'>SAMPLE MENU MARKUP FOR MENU ["+this.taxonomyDs.module.Tag+"]</h1></ul>"];
		for(var i = 0; i < datasourceNodes.length; i++) {
			if (window.console) { window.console.log('SimpleMenuRender>> '+datasourceNodes[i].title+' <<'); }
			markup.push('<li><h2>'+datasourceNodes[i].title+'</h2></li>');
		}
		markup.push('</ul>');

		return markup.join('');
	}
}

function MegaMenuRender(taxonomyDs) {
	this.taxonomyDs = taxonomyDs && typeof(taxonomyDs) === 'object' ? taxonomyDs : null;
	return { renderAsString: renderMenuAsString.bind(this) }

	function renderMenuAsString(datasourceNodes, $domContainer) {
		var markup = ["<nav id='"+this.taxonomyDs.module.Tag+"'><ul class='nav'>"];
		for(var i = 0; i < datasourceNodes.length; i++) {
			markup.push(renderNode(datasourceNodes[i]));
		}
		markup.push('</ul></nav>');
		return markup.join('');
	}

	function renderNode(node) {
		var markup = [];
		node.title = node.title.replace(/[_]*$/gi, '').replace(/ and /gi, ' & ');
		if (window.console) { window.console.log('MegaMenuRender>> render node: '+node.title+' <<'); }
		switch (node.nodeType) {
			case 'Root': {
				markup.push("<li>");
				markup.push(String.format("<a class='{3}' href='{2}' id='{0}' title='{4}'>{1}</a>", node.termId, node.title, node.navigateUrl || 'javascript:;', node.cssClass, node.hoverText));
				if (node.childNodes && node.childNodes.length) {
					/* has child Columns, iterate and render each column */
					markup.push("<div>");
					for(var cx = 0; cx < node.childNodes.length; cx++) {
						markup.push(renderNode(node.childNodes[cx]));
					}
					markup.push("</div>");
				}
				markup.push("</li>");
				break;
			}
			case 'Column': {
				markup.push(String.format("<div class='{1}' id='{0}'>", node.termId, node.cssClass));
				if (node.childNodes && node.childNodes.length) {
					/* has child Sections, iterate and render each section */
					for(var sx = 0; sx < node.childNodes.length; sx++) {
						markup.push(renderNode(node.childNodes[sx]));
					}
				}
				markup.push("</div>");
				break;
			}
			case 'Section': {
				markup.push("<h3>");
				if (node.navigateUrl && node.navigateUrl.length) {
					markup.push(String.format("<a class='{3}' href='{2}' id='{0}' title='{4}'>{1}</a>", node.termId, node.title, node.navigateUrl, node.cssClass, node.hoverText));
				} else {
					markup.push(String.format("{0}", node.title));
				}
				markup.push("</h3><ul>");
				if (node.childNodes && node.childNodes.length) {
					/* has child Links, iterate and render each link */
					for(var lx = 0; lx < node.childNodes.length; lx++) {
						markup.push(renderNode(node.childNodes[lx]));
					}
				}
				markup.push("</ul>");
				break;
			}
			default: {
				markup.push(String.format("<li><a class='{3}' href='{2}' id='{0}' title='{4}'>{1}</a></li>", node.termId, node.title, node.navigateUrl || 'javascript:;', node.cssClass, node.hoverText));
				break;
			}
		}
		return markup.join('');
	}
}

$(function() {
	var DurStartTime = new Date();

	function OnMenuRendered(taxonomyDs) {
		if (window.console) { console.log('TaxonomyDatastore ['+taxonomyDs.Id+'] is ready to render!!'); }
		taxonomyDs.module.render($container, new MegaMenuRender(taxonomyDs));
		$container.css({opacity:'1'});

		var DurEndTime = new Date(), elapse = (DurEndTime.getTime()) - (DurStartTime.getTime());
		if (window.console) { console.log('TaxonomyDatastore ['+taxonomyDs.Id+'] initialisation and render time: ' + (elapse)+'ms'); }
	}

	var
		$container = $('#main-menu').css({opacity:'.2'}),
		sideTermsetId = '18278814-4c62-4a77-8478-723d27f4369f', megaTermsetId = '966c85b8-5344-4350-a22b-79335e3906c7', 
		cacheDurationHours = 24,
		taxDs = new RB.Masterpage.TaxonomyDatastore(megaTermsetId, cacheDurationHours);
	taxDs.initialise();
	taxDs.isInitialised.done(OnMenuRendered);
});

})(window,jQuery);
