( function( window, $ ) {
	"use strict";

	function TreeRender( taxonomyDs ) {
		this.taxonomyDs = taxonomyDs && typeof( taxonomyDs ) === 'object' ? taxonomyDs : null;
		return {
			renderAsString: renderMenuAsString.bind( this )
		};

		function renderMenuAsString( datasourceNodes, $domContainer ) {
			var markup = [ "<nav id='" + this.taxonomyDs.Tag + "'><ul>" ];
			for ( var i = 0; i < datasourceNodes.length; i++ ) {
				markup.push( renderNode( datasourceNodes[ i ], 0 ) );
			}
			markup.push( '</ul></nav>' );
			return markup.join( '' );
		}

		function renderNode( node, depth ) {
			var markup = [];
			node.title = node.title.replace( /[_]*$/gi, '' ).replace( / and /gi, ' & ' );
			if ( window.console ) {
				window.console.log( 'TreeRender>> render node: ' + node.title + ' <<' );
			}
			switch ( node.nodeType ) {
				default: {
					markup.push( String.format( "<li data-depth='{1}'><h3>{0}</h3>", node.title, depth ) );
					if ( node.childNodes && node.childNodes.length ) {
						markup.push( String.format( "<ul style='margin-left:{0}px;'>", 25 ) );
						/* has child Links, iterate and render each link */
						for ( var lx = 0; lx < node.childNodes.length; lx++ ) {
							markup.push( renderNode( node.childNodes[ lx ], depth + 1 ) );
						}
						markup.push( "</ul>" );
					}
					markup.push( "</li>" );
					break;
				}
			}
			return markup.join( '' );
		}
	}

	function OnTreeDatastoreReady( $container, durStartTime, taxonomyDs ) {
		if ( window.console ) {
			window.console.log( 'OnTreeDatastoreReady>> TaxonomyDatastore [' + taxonomyDs.Id + '] is ready' );
		}
		taxonomyDs.render( $container, new TreeRender( taxonomyDs ) );
		$container.css( {
			opacity: '1'
		} );

		var ellapsed = ( ( new Date() ).getTime() ) - ( durStartTime.getTime() );
		if ( window.console ) {
			window.console.log( 'OnTreeDatastoreReady>> TaxonomyDatastore [' + taxonomyDs.Id + '] ellapsed time: ' + ( ellapsed ) + 'ms' );
		}
		return taxonomyDs;
	}

	function OnTreeDatastoreReady2( $container, timeout, taxonomyDs ) {
		if ( window.console ) {
			window.console.log( 'OnTreeDatastoreReady2>> TaxonomyDatastore [' + taxonomyDs.Id + '] is ready' );
		}
		setTimeout( function() {
			$( String.format( "<h2 style='display:none;'>This cache expires at: {0}</h2>", taxonomyDs.cache.expiresOn.format( 'yyyy-MM-dd HH:mm:ss.fff' ) ) )
				.prependTo( $container ).slideDown( 1000 );
		}, timeout );
		return taxonomyDs;
	}

	$( function() {
		var
			durStartTime = new Date(),
			$container = $( '#sidenavigation' ).css( {
				opacity: '.2'
			} ),
			termsetId = '18278814-4c62-4a77-8478-723d27f4369f',
			cacheDisabled = -1,
			cacheDurationHours = 24,
			taxDs = new RB.Masterpage.TaxonomyDatastore( termsetId, RB.Storagetype.session, cacheDurationHours );
		if ( window.console ) {
			window.console.log( 'Tree.js>> TaxonomyDatastore [' + taxDs.Tag + '] ' + durStartTime.format( 'yyyy-MM-dd HH:mm:ss.fff' ) );
		}
		taxDs.initialise();
		taxDs.isInitialised
			.then( OnTreeDatastoreReady.bind( null, $container, durStartTime ) )
			.then( OnTreeDatastoreReady2.bind( null, $container, 2000 ) );
	} );

} )( window, jQuery );