( function( window, $ ) {
	"use strict";

	window.RB = window.RB || {};
	RB.Masterpage = RB.Masterpage || {};

	function log( message ) {
		if ( window.console ) {
			if ( window.RB && window.RB.Masterpage && window.RB.Masterpage.Log ) RB.Masterpage.Log( message );
			else window.console.log( message );
		}
	}

	/* START TAXONOMY */
	RB.Storagetype = RB.Storagetype || {
		local: 0,
		session: 1
	};
	RB.Masterpage.IsStorageSupported = function() {
		try {
			return ( 'sessionStorage' in window ) && ( window[ 'sessionStorage' ] !== null ) && ( 'localStorage' in window ) && ( window[ 'localStorage' ] !== null );
		} catch ( e ) {
			return false;
		}
	}
	RB.Masterpage.Storage = function( cacheId, durationSeconds, storageType, cacheSlots ) {
		if ( !RB.Masterpage.IsStorageSupported() ) {
			throw new Error( 'RB.Masterpage.Storage>> local and/or session storage is not supported by the browser!!' );
		}

		if ( typeof( storageType === 'number' ) && ( storageType === RB.Storagetype.session ) ) {
			this.storageType = 'RB.Storagetype.session';
			this.storage = sessionStorage;
		} else {
			this.storageType = 'RB.Storagetype.local';
			this.storage = localStorage;
		}

		this.cacheId = cacheId;
		this.timestampCacheId = cacheId + '-timestamp';
		this.durationSecs = typeof( durationSeconds ) === 'number' ? Math.max( 0, durationSeconds ) : 24 * 60 * 60;
		this.cacheSlots = cacheSlots && ( Object.prototype.toString.call( cacheSlots ) === '[object Array]' ) ? cacheSlots : [];

		var expiryStamp = this.storage.getItem( this.timestampCacheId );
		if ( expiryStamp && expiryStamp.length ) {
			this.expiresOn = new Date( parseInt( expiryStamp ) + ( this.durationSecs * 1000 ) );
		} else {
			var expires = ( new Date().getTime() );
			this.expiresOn = new Date( expires + ( this.durationSecs * 1000 ) );
		}

		this.isExpired = isExpired.bind( this );
		this.hasValue = hasValue.bind( this );
		this.getValue = getValue.bind( this );
		this.setValue = setValue.bind( this );
		this.remove = remove.bind( this );
		return this;

		function remove( cacheSlot ) {
			if ( cacheSlot && cacheSlot.length ) {
				if ( this.cacheSlots.indexOf( cacheSlot ) >= 0 ) {
					this.storage.removeItem( this.cacheId + '-' + cacheSlot );
				}
			} else {
				this.storage.removeItem( this.cacheId );
				for ( var i = 0; i < this.cacheSlots.length; i++ ) {
					this.storage.removeItem( this.cacheId + '-' + this.cacheSlots[ i ] );
				}
				this.storage.removeItem( this.timestampCacheId );
			}
		}

		function isExpired() {
			var expiryStamp = this.storage.getItem( this.timestampCacheId );
			if ( expiryStamp == null || !expiryStamp.length ) return true;
			if ( this.durationSecs > 0 ) {
				var
					currentTime = Math.floor( ( new Date().getTime() ) / 1000 ),
					expiryTime = Math.floor( ( new Date( parseInt( expiryStamp ) ).getTime() ) / 1000 );
				if ( ( currentTime - expiryTime ) > parseInt( this.durationSecs ) ) {
					return true; /* expired */
				} else {
					return false;
				}
			} else {
				/* this.durationSecs === 0 */
				return false; /* wierdly, cache never expires */
			}
		}

		function getValue( cacheSlot ) {
			var value = !cacheSlot || !cacheSlot.length ? this.storage.getItem( this.cacheId ) : this.cacheSlots.indexOf( cacheSlot ) >= 0 ? this.storage.getItem( this.cacheId + '-' + cacheSlot ) : null;
			return value;
		}

		function hasValue( cacheSlot ) {
			var value = this.getValue( typeof cacheSlot === 'undefined' ? null : cacheSlot );
			return ( value && value.length ) ? true : false;
		}

		function setValue( newValue, cacheSlot ) {
			if ( !cacheSlot || !cacheSlot.length ) {
				this.storage.setItem( this.cacheId, newValue || '' );

				/* setting the value of the primary cache value resets the 'slotted' cache values */
				for ( var i = 0; i < this.cacheSlots.length; i++ ) {
					this.storage.removeItem( this.cacheId + '-' + this.cacheSlots[ i ] );
				}
			} else {
				/* don't update the expiry stamp for setting a 'slotted' cache value */
				if ( this.cacheSlots.indexOf( cacheSlot ) >= 0 ) {
					this.storage.setItem( this.cacheId + '-' + cacheSlot, newValue || '' );
				}
				return;
			}
			/* update cache expiry */
			var expires = ( new Date().getTime() );
			this.expiresOn = new Date( expires + ( this.durationSecs * 1000 ) );
			this.storage.setItem( this.timestampCacheId, expires );
		}
	} /* end of RB.Masterpage.Storage */

	RB.Masterpage.TaxonomyDatastore = function( termSetId, cacheType, cacheDurationHours ) {
			if ( typeof( cacheType ) === 'undefined' ) cacheType = RB.Storagetype.local;
			if ( typeof( cacheDurationHours ) === 'undefined' ) cacheDurationHours = 24 * 60 * 60;
			else if ( typeof( cacheDurationHours ) === 'number' && cacheDurationHours >= 0 ) cacheDurationHours = cacheDurationHours * 60 * 60;
			else cacheDurationHours = -1;

			termSetId = termSetId.replace( /[{}]*/gi, '' );
			var self = this;
			this.Id = termSetId.replace( /-/gi, '' );
			this.cache = cacheDurationHours >= 0 ? new RB.Masterpage.Storage( 'RB$Datastore-' + this.Id, cacheDurationHours, cacheType, [ 'Markup' ] ) : null;
			this.Tag = this.Id;
			this.initialise = initialise.bind( this );
			this.render = renderTerms.bind( this );
			this.isInitialised = new $.Deferred();
			this.nodes = [];

			RB.Masterpage.TaxonomyDatastore.Instances = RB.Masterpage.TaxonomyDatastore.Instances || {};
			RB.Masterpage.TaxonomyDatastore.Instances[ this.Id ] = this;
			return this;

			function initialise() {
				log( 'TaxonomyDatastore>> [' + this.Id + '] cache type is ' + ( this.cache ? this.cache.storageType : 'disabled' ) );
				if ( this.cache && this.cache.hasValue() && !this.cache.isExpired() ) {
					log( 'TaxonomyDatastore>> [' + this.Id + '] datasource being served from cache' );
					var cached = JSON.parse( this.cache.getValue() );
					this.Tag = cached.Tag;
					this.nodes = cached.nodes;
					this.isInitialised.resolve( this );
					return;
				}
				SP.SOD.loadMultiple( [ 'sp.js' ], function() {
					log( 'TaxonomyDatastore>> SP.js loaded' );
					SP.SOD.registerSod( 'sp.taxonomy.js', SP.Utilities.Utility.getLayoutsPageUrl( 'sp.taxonomy.js' ) );
					SP.SOD.loadMultiple( [ 'sp.taxonomy.js' ], function() {
						log( 'TaxonomyDatastore>> sp.taxonomy.js loaded' );
						var
							ctx = SP.ClientContext.get_current(),
							taxonomySession = SP.Taxonomy.TaxonomySession.getTaxonomySession( ctx ),
							termStore = taxonomySession.getDefaultSiteCollectionTermStore(),
							termSet = termStore.getTermSet( termSetId ),
							terms = termSet.getAllTerms();
						ctx.load( termSet );
						ctx.load( terms );
						ctx.executeQueryAsync( function( sender, args ) {
							self.Tag = termSet.get_name().replace( / /gi, '' ) + '-' + self.Id
							buildTermNodeTreeFromFlatList.call( self, terms, termSet );
						}, function( sender, args ) {
							/* handle error */
							var m = args.get_message();
							throw new Error( String.format( "TaxonomyDatastore>> [{1}] error: {0}", m, self.Id ) );
						} );
					} );
				} );
			}

			function buildTermNodeTreeFromFlatList( terms, termSet ) {
				var
					termsEnumerator = terms.getEnumerator(),
					nodeTree = {
						customSortOrder: termSet && termSet.get_customSortOrder ? termSet.get_customSortOrder() || '' : '',
						childNodes: []
					};

				/* iterate each term */
				while ( termsEnumerator.moveNext() ) {
					var
						currentTerm = termsEnumerator.get_current(),
						currentTermProperties = currentTerm.get_localCustomProperties(),
						currentTermNodeType = currentTermProperties[ "_Rb_Nav_Type" ] || '',
						currentTermPath = currentTerm.get_pathOfTerm().split( ';' ),
						currentChildNodes = nodeTree.childNodes;

					/* iterate each segment of the current terms path */
					for ( var i = 0; i < currentTermPath.length; i++ ) {
						var foundNode = false;
						/* find this node in the current set of childNodes */
						for ( var z = 0; z < currentChildNodes.length; z++ ) {
							if ( currentChildNodes[ z ].name === currentTermPath[ i ] ) {
								foundNode = true;
								break;
							}
						}
						/* select the child node for the current term path, OR, create a new one */
						var termNode = foundNode ? currentChildNodes[ z ] : {
							name: currentTermPath[ i ],
							childNodes: []
						};

						/* if we're the last term path segment, add the term properties */
						if ( i === currentTermPath.length - 1 ) {
							termNode.properties = {};
							termNode.nodeType = currentTermNodeType;
							termNode.title = currentTerm.get_name();
							termNode.termId = currentTerm.get_id().toString();
							termNode.customSortOrder = currentTerm.get_customSortOrder ? currentTerm.get_customSortOrder() || '' : '';
							termNode.cssClass = currentTermProperties[ "_Rb_Nav_CssClass" ] || '';
							if ( !currentTermNodeType.match( /column/gi ) ) {
								if ( currentTermNodeType === 'Section' ) {
									if ( currentTermProperties[ "_Sys_Nav_SimpleLinkUrl" ] ) {
										termNode.navigateUrl = currentTermProperties[ "_Sys_Nav_SimpleLinkUrl" ] || '';
										termNode.hoverText = currentTermProperties[ "_Sys_Nav_HoverText" ] || '';
									}
									termNode.properties = currentTermProperties;
								} else if ( currentTermNodeType === 'Root' ) {
									termNode.navigateUrl = currentTermProperties[ "_Sys_Nav_SimpleLinkUrl" ] || '';
									termNode.hoverText = currentTermProperties[ "_Sys_Nav_HoverText" ] || '';
									termNode.properties = currentTermProperties;
								} else {
									/* termNode.term = currentTerm; */
									termNode.description = currentTerm.get_description() || '';
									termNode.navigateUrl = currentTermProperties[ "_Sys_Nav_SimpleLinkUrl" ] || '';
									termNode.hoverText = currentTermProperties[ "_Sys_Nav_HoverText" ] || '';
									termNode.properties = currentTermProperties;
								}
							}
						}

						/* if there was a termnode for the current term path, set the current childNodes as that termNodes child nodes for the next term path iteration */
						if ( foundNode ) {
							currentChildNodes = termNode.childNodes;
						} else {
							/* we created a new termNode for the current term path, add it to the current set of childNodes */
							currentChildNodes.push( termNode );

							/* if this term path is not the last, set the current childNodes as that termNodes child nodes for the next term path iteration */
							if ( i !== currentTermPath.length - 1 ) {
								currentChildNodes = termNode.childNodes;
							}
						}
					}
				}

				var n = applySortOrdering( nodeTree );
				this.nodes = n && n.childNodes ? n.childNodes : [];
				/* cache the built data tree */
				if ( this.cache ) {
					this.cache.setValue( JSON.stringify( this ) );
				}
				/* signal the datasource is initialised */
				this.isInitialised.resolve( this );
			}

			function applySortOrdering( nodeTree ) {
				/* if the node has child nodes and a custom sort order property, sort this nodes child nodes */
				if ( nodeTree.childNodes.length && typeof( nodeTree.customSortOrder ) !== 'undefined' ) {
					var sortOrder = nodeTree.customSortOrder || '';

					/* if sortOrder is not null, the custom sort order is a string of term id's (guids), delimited by a : */
					if ( sortOrder && sortOrder.length ) {
						sortOrder = sortOrder.split( ':' );
						nodeTree.childNodes.sort( function( a, b ) {
							var
								idxA = sortOrder.indexOf( a.termId ),
								idxB = sortOrder.indexOf( b.termId );
							if ( idxA > idxB ) {
								return 1;
							} else if ( idxA < idxB ) {
								return -1;
							}
							return 0;
						} );
					} else {
						/* if sortOrder is falsey, sort nodes by title */
						nodeTree.childNodes.sort( function( a, b ) {
							if ( a.title > b.title ) {
								return 1;
							} else if ( a.title < b.title ) {
								return -1;
							}
							return 0;
						} );
					}
				}

				/* now sort the child nodes of each child node */
				for ( var i = 0; i < nodeTree.childNodes.length; i++ ) {
					nodeTree.childNodes[ i ] = applySortOrdering( nodeTree.childNodes[ i ] );
				}
				return nodeTree;
			}

			function renderTerms( domContainer, renderer ) {
				if ( typeof( domContainer ) === 'undefined' || !domContainer ) {
					throw new Error( 'TaxonomyDatastore>> [' + this.Id + '] no domContainer parameter supplied!' );
				}
				var isCached = this.cache && this.cache.hasValue( 'Markup' );
				if ( window.console ) {
					if ( isCached ) {
						log( 'TaxonomyDatastore>> [' + this.Id + '] Markup being served from cache' );
					}
					log( 'TaxonomyDatastore>> render [' + this.Id + '][' + this.Tag + '] at ' + domContainer );
				}

				var $domContainer = null;
				if ( typeof( domContainer ) === 'string' ) {
					$domContainer = $( domContainer );
				} else if ( typeof( domContainer ) === 'object' && domContainer && domContainer.html ) {
					/* assume domContainer is a jQuery object */
					$domContainer = domContainer;
				}

				var markup = isCached ? [ this.cache.getValue( 'Markup' ) ] : [];
				if ( !isCached || !markup.length ) {
					/* invalid or no cached markup - build it using the supplied renderer */
					isCached = false;
					markup = [];

					if ( renderer && ( typeof( renderer ) === 'object' ) && renderer.renderAsString && typeof( renderer.renderAsString ) === 'function' ) {
						var m = renderer.renderAsString( this.nodes, $domContainer );
						if ( m && m.length )
							markup.push( m );
					} else {
						throw new Error( "TaxonomyDatastore>> No Renderer supplied, or Renderer supplied does not have a 'renderAsString(...)' method!" );
					}
				}

				markup = markup.join( '' );
				if ( $domContainer && markup ) {
					$domContainer.html( markup );
				}

				if ( !isCached && this.cache && markup && markup.length ) {
					this.cache.setValue( markup, 'Markup' );
				}
			}
		}
		/* end of RB.Masterpage.TaxonomyDatastore */


	RB.Masterpage.Megamenu = function() {
		var
			_module = {
				EnsureSetup: ensureSetup,
				Close: closeSidr
			};
		return _module;

		function MegaMenuRender( taxonomyDs ) {
			this.taxonomyDs = taxonomyDs && typeof( taxonomyDs ) === 'object' ? taxonomyDs : null;
			return {
				renderAsString: renderMenuAsString.bind( this )
			};

			function renderMenuAsString( datasourceNodes, $domContainer ) {
				var markup = [ "<nav id='" + this.taxonomyDs.Tag + "'><ul class='nav'>" ];
				for ( var i = 0; i < datasourceNodes.length; i++ ) {
					markup.push( renderNode( datasourceNodes[ i ] ) );
				}
				markup.push( '</ul></nav>' );
				return markup.join( '' );
			}

			function renderNode( node ) {
				var
					markup = [],
					icon = node.properties[ "_Rb_Nav_Icon" ] || '',
					target = node.properties[ "_Rb_Nav_NewWindow" ] || '';
				if ( icon && icon.length ) {
					if ( icon.match( /^fa[-]?|^flaticon-/gi ) ) {
						/* match a fontawesome or flaticon glyph */
						icon = String.format( '<i class="{0}"></i>', icon );
					} else if ( icon.match( /^\/[\/]?|^http[s]?:/gi ) ) {
						/* match an image url */
						icon = String.format( '<img src="{0}"></i>', icon );
					} else icon = '';
				}
				if ( target && target.length ) {
					target = target.match( /^true$/gi ) ? '_blank' : '';
				}

				node.title = node.title.replace( /[_]*$/gi, '' ).replace( / and /gi, ' & ' );
				log( 'MegaMenuRender>> render node: ' + node.title + ' <<' );
				switch ( node.nodeType ) {
					case 'Root':
						{
							markup.push( "<li>" );
							markup.push( String.format( "<a class='{3}' href='{2}' id='{0}' title='{4}' target='{5}'>{6}{1}</a>", node.termId, node.title, node.navigateUrl || 'javascript:;', node.cssClass, node.hoverText, target, icon ) );
							if ( node.childNodes && node.childNodes.length ) {
								/* has child Columns, iterate and render each column */
								markup.push( "<div>" );
								for ( var cx = 0; cx < node.childNodes.length; cx++ ) {
									markup.push( renderNode( node.childNodes[ cx ] ) );
								}
								markup.push( "</div>" );
							}
							markup.push( "</li>" );
							break;
						}
					case 'Column':
						{
							markup.push( String.format( "<div class='{1}' id='{0}'>", node.termId, node.cssClass ) );
							if ( node.childNodes && node.childNodes.length ) {
								/* has child Sections, iterate and render each section */
								for ( var sx = 0; sx < node.childNodes.length; sx++ ) {
									markup.push( renderNode( node.childNodes[ sx ] ) );
								}
							}
							markup.push( "</div>" );
							break;
						}
					case 'Section':
						{
							markup.push( "<h3>" );
							if ( node.navigateUrl && node.navigateUrl.length ) {
								markup.push( String.format( "<a class='{3}' href='{2}' id='{0}' title='{4}' target='{5}'>{6}{1}</a>", node.termId, node.title, node.navigateUrl, node.cssClass, node.hoverText, target, icon ) );
							} else {
								markup.push( String.format( "{1}{0}", node.title, icon ) );
							}
							markup.push( "</h3><ul>" );
							if ( node.childNodes && node.childNodes.length ) {
								/* has child Links, iterate and render each link */
								for ( var lx = 0; lx < node.childNodes.length; lx++ ) {
									markup.push( renderNode( node.childNodes[ lx ] ) );
								}
							}
							markup.push( "</ul>" );
							break;
						}
					default:
						{
							markup.push( String.format( "<li><a class='{3}' href='{2}' id='{0}' title='{4}' target='{5}'>{6}{1}</a></li>", node.termId, node.title, node.navigateUrl || 'javascript:;', node.cssClass, node.hoverText, target, icon ) );
							break;
						}
				}
				return markup.join( '' );
			}
		}

		function closeSidr() {
			$.sidr( 'close', 'sidr-existing-content' );
		}

		function ensureSetup() {
			var
				durStartTime = new Date(),
				$megaContainer = $( '#main-menu' ).css( {
					opacity: '.2'
				} );

			function OnDatastoreReady( taxonomyDs ) {
				log( 'OnDatastoreReady>> TaxonomyDatastore [' + taxonomyDs.Id + '] is ready' );
				taxonomyDs.render( $megaContainer, new MegaMenuRender( taxonomyDs ) );
				$megaContainer.css( {
					opacity: '1'
				} );

				var ellapsed = ( ( new Date() ).getTime() ) - ( durStartTime.getTime() );
				log( 'OnDatastoreReady>> TaxonomyDatastore [' + taxonomyDs.Id + '] ellapsed time: ' + ( ellapsed ) + 'ms' );

				/* init SIDR for the megamenu */
				$( '#mobile-nav' ).sidr( {
					name: 'sidr-existing-content',
					source: '#main-menu',
					onOpen: function() {
						$( '#mobile-nav' ).addClass( 'active' );
						if ( typeof( CalloutManager ) !== 'undefined' ) CalloutManager.closeAll();
					},
					onClose: function() {
						$( '#mobile-nav' ).removeClass( 'active' );
					}
				} );

				/* toggle off canvas menu */
				$( '.sidr-class-nav-column ul' ).hide();
				$( '.sidr-inner h3' ).click( function( e ) {
					e.preventDefault();
					var ullist = $( this ).parent().children( 'ul:first' );
					if ( ullist.is( ':visible' ) ) {
						ullist.hide( '5000' );
					} else {
						ullist.show( '5000' );
					}
				} );
			}

			log( 'RB.Masterpage.Megamenu>> about to load web properties' );
			RB.Masterpage.LoadWebproperties().done( function( webProperties ) {
				/* allow the Termset used for the Megamenu to be overidden on a per-web 
				basis using a Web propertybag value
				*/
				var
					perWebTermSetId = webProperties[ "RbMasterpageMegaMenuTermsetId" ],
					megaTermsetId = typeof( perWebTermSetId ) === 'string' && perWebTermSetId && perWebTermSetId.length ? perWebTermSetId : '966c85b8-5344-4350-a22b-79335e3906c7',
					cacheDurationHours = 24,
					taxDs = new RB.Masterpage.TaxonomyDatastore( megaTermsetId, RB.Storagetype.local, cacheDurationHours );
				taxDs.initialise();
				taxDs.isInitialised.done( OnDatastoreReady );
			} );
		}
	}();

} )( window, jQuery );