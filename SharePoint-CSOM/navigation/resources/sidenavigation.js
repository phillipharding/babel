( function( window, $ ) {
	"use strict";

	function log( message ) {
		if ( window.console ) {
			if ( window.RB && window.RB.Masterpage && window.RB.Masterpage.Log ) RB.Masterpage.Log( message );
			else window.console.log( message );
		}
	}

	function SideNavigationRender( taxonomyDs ) {
		this.taxonomyDs = taxonomyDs && typeof( taxonomyDs ) === 'object' ? taxonomyDs : null;
		return {
			renderAsString: renderMenuAsString.bind( this )
		};

		function renderMenuAsString( datasourceNodes, $domContainer ) {
			var markup = [ "<nav class='tax-sidenav0-default' id='" + this.taxonomyDs.Tag + "'>" ];
			for ( var i = 0; i < datasourceNodes.length; i++ ) {
				markup.push( renderNode( datasourceNodes[ i ], 0 ) );
			}
			markup.push( '</nav>' );
			return markup.join( '' );
		}

		function elAttributesFromNode( node ) {
			var
				icon = node.properties[ "_Rb_Nav_Icon" ] || '',
				target = node.properties[ "_Rb_Nav_NewWindow" ] || '';
			if ( icon && icon.length ) {
				if ( icon.match( /^fa[-]?|^flaticon-/gi ) ) {
					/* match a fontawesome or flaticon glyph */
					icon = String.format( '<i class="{0}"></i>&nbsp;', icon );
				} else if ( icon.match( /^\/[\/]?|^http[s]?:/gi ) ) {
					/* match an image url */
					icon = String.format( '<img src="{0}">&nbsp;', icon );
				} else icon = '';
			}
			if ( target && target.length ) {
				target = target.match( /^true$/gi ) ? '_blank' : '';
			}
			return {
				icon: icon,
				target: target
			};
		}

		function renderNode( node, depth ) {
			var
				markup = [],
				hasChildNodes = node.childNodes && node.childNodes.length,
				elAttrs = elAttributesFromNode( node );
			node.title = node.title.replace( /[_]*$/gi, '' ).replace( / and /gi, ' & ' );
			if (node.navigateUrl && node.navigateUrl.length) {
				node.navigateUrl = node.navigateUrl.replace( /^~sitecollection/gi, _spPageContextInfo.siteServerRelativeUrl ).replace( /^~site/gi, _spPageContextInfo.webServerRelativeUrl );
			}
			log( 'SideNavigationRender>> render node: ' + node.title + ' <<' );

			if ( depth === 0 || hasChildNodes ) {
				if ( depth > 0 && hasChildNodes ) {
					markup.push( String.format( "<li class='group {0}'>", node.cssClass ) );
				}
				markup.push( String.format( "<h1 class='{0} {1}' title='{2}'>", hasChildNodes ? 'expando' : '', node.cssClass, node.hoverText ) );
				if ( !hasChildNodes && ( node.navigateUrl && node.navigateUrl.length ) ) {
					markup.push( String.format( "<a class='{3}' href='{2}' id='{0}' title='{4}' target='{5}'>{6}{1}</a>",
						node.termId, node.title, node.navigateUrl, node.cssClass, node.hoverText, elAttrs.target, elAttrs.icon ) );
				} else {
					markup.push( String.format( "<span class='{2}'>{1}{0}</span>", node.title, elAttrs.icon, node.cssClass ) );
				}
				if ( hasChildNodes ) markup.push( '<i class="fa fa-chevron desktop"></i><i class="fa fa-bars mobile"></i>' );
				markup.push( '</h1>' );

				if ( hasChildNodes ) {
					/* has child Columns, iterate and render each column */
					markup.push( String.format( "<ul class='{0}'>", node.cssClass ) );
					for ( var cx = 0; cx < node.childNodes.length; cx++ ) {
						var childNode = node.childNodes[ cx ];
						markup.push( renderNode( childNode, depth + 1 ) );
					}
					markup.push( "</ul>" );
					if ( depth > 0 ) {
						markup.push( "</li>" );
					}
				}
			} else {
				markup.push( String.format( "<li class='{0} {1}' title='{2}'>", node.navigateUrl && node.navigateUrl.length ? 'link' : 'text', node.cssClass, node.hoverText ) );
				if ( node.navigateUrl && node.navigateUrl.length ) {
					markup.push( String.format( "<a class='{3}' href='{2}' id='{0}' title='{4}' target='{5}'>{6}{1}</a>",
						node.termId, node.title, node.navigateUrl, node.cssClass, node.hoverText, elAttrs.target, elAttrs.icon ) );
				} else {
					markup.push( String.format( "<span class='{2}'>{1}{0}</span>", node.title, elAttrs.icon, node.cssClass ) );
				}
				markup.push( "</li>" );
			}

			return markup.join( '' );
		}
	}

	function OnSideNavigationDatastoreReady( $container, taxonomyDs ) {
		if ( window.console ) {
			window.console.log( 'OnSideNavigationDatastoreReady>> TaxonomyDatastore [' + taxonomyDs.Id + '] is ready' );
		}
		taxonomyDs.render( $container, new SideNavigationRender( taxonomyDs ) );
		$container
			.css( { opacity: '1' } )
			.find( 'h1.expando' ).on( 'click', function( e ) {
				$( this ).toggleClass( 'open' ).next( 'ul' ).toggleClass( 'open' );
			} );

	}
	function InitialiseSideNavigation() {
		var
			$container = $( '#buzz-sidenavigation' ).css( { opacity: '.2' } ),
			termsetId = '18278814-4c62-4a77-8478-723d27f4369f',
			cacheDisabled = -1,
			cacheDurationHours = 24,
			taxDs = new RB.Masterpage.TaxonomyDatastore( termsetId, RB.Storagetype.local, cacheDurationHours );
		if ( window.console ) {
			window.console.log( 'Tree.js>> TaxonomyDatastore [' + taxDs.Tag + '] ' );
		}
		taxDs.initialise();
		taxDs.isInitialised
			.then( OnSideNavigationDatastoreReady.bind( null, $container ) );
	}

	$(InitialiseSideNavigation);

} )( window, jQuery );
