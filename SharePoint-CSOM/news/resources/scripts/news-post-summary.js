(function() {
/*
	CSR display template
	JSLink = sp.ui.blogs.js|~sitecollection/_catalogs/masterpage/Display Templates/news-post-summary.js
*/

window.csr = window.csr || {};
csr.templateoverride = function() {
	var
		ctxOverride = {}, 
		module = {
			register: function() {
				SPClientTemplates.TemplateManager.RegisterTemplateOverrides(ctxOverride);
			}
		};
	ctxOverride = {
		OnPreRender: OnPreRender,
		Templates: {
			View: ViewRender,
			Body: BodyRender,
			Header: HeaderRender,
			Footer: FooterRender,
			Item: ItemRender,
			Fields: {
				'Title': {'View': FieldTitleViewRender },
				'Body': {'View': FieldBodyViewRender }
			}
		},
		OnPostRender: OnPostRender,
		ListTemplateType: 301
		/*BaseViewID: 0*/
	};

	function ViewRender(ctx) {
		console.log(String.format(">>In ViewRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		return "";
	}
	function BodyRender(ctx) {
		console.log(String.format(">>In BodyRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		return "";
	}
	function FieldTitleViewRender(ctx) {
		console.log(String.format(">>In FieldTitleViewRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		/* close the <A/> and <H2/> tags first */

		var html = '', headerimage = '';
		if (ctx.CurrentItem.NewsRollupImage) {
			headerimage = String.format("<div class='news-post-title-image'>{0}</div>",ctx.CurrentItem.NewsRollupImage);
		}
		if (ctx.BaseViewID == 0 || ctx.BaseViewID == 7) {
		/* summary view or post view */
			html = String.format("</a></h2><h2 class='news-post-title'>{3}<a href='{0}/Post.aspx?ID={1}' class=''>{2}</a></h2>",
								ctx.listUrlDir,
								ctx.CurrentItem.ID,
								ctx.CurrentItem.Title,
								headerimage);
		} else if (ctx.BaseViewID == 9 || ctx.BaseViewID == 8) {
		/* category view or date (range) view */
			var body = String.format("<div class='news-post-bodysummary'>{2}<div class='ellipsis'><a href='{0}/Post.aspx?ID={1}' class=''>&hellip;</a></div></div>", 
								ctx.listUrlDir,
								ctx.CurrentItem.ID,
								ctx.CurrentItem.Body);
			html = String.format("</a></h2><h2 class='news-post-title'>{3}<a href='{0}/Post.aspx?ID={1}' class=''>{2}</a></h2>{4}",
								ctx.listUrlDir,
								ctx.CurrentItem.ID,
								ctx.CurrentItem.Title,
								headerimage,
								body);
		} else {
		/* some other view I don't know about */
			html = ctx.CurrentItem.Title;
		}
		
		/*for(var k in ctx.CurrentItem) {
			console.log(String.format(">>{0} = {1}", k, ctx.CurrentItem[k]));
		}*/

		return html;
	}
	function FieldBodyViewRender(ctx) {
		console.log(String.format(">>In FieldBodyViewRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		var html = "";
		if (ctx.CurrentItem.NewsPageImage) {
			html = String.format("<div class='news-post-pageimage'>{0}</div>",ctx.CurrentItem.NewsPageImage);
		}
		html += ctx.CurrentItem.Body;
		/* remove ZWB (zero width breaks which sharepoint occasionally puts in the markup for rich html field content */
		html = html.replace(/\u200B/g,'');
		return html;
	}
	function OnPreRender(ctx) {
		console.log(String.format(">>In OnPreRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
	}
	function HeaderRender(ctx) {
		console.log(String.format(">>In HeaderRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		return "<div class='new-post-summary'>";
	}
	function FooterRender(ctx) {
		console.log(String.format(">>In FooterRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		return "</div>";
	}
	function ItemRender(ctx) {
		console.log(String.format(">>In ItemRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		var html = '';
		for(var k in ctx.CurrentItem) {
			html += String.format("<div>{0} = {1}</div>", k, ctx.CurrentItem[k]);
		}
		return html;
	}
	function OnPostRender(ctx) {
		console.log(String.format(">>In OnPostRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
	}

	return module;
}();

function RegisterContext() {
	SP.SOD.executeFunc("clienttemplates.js", "SPClientTemplates", function() {
		csr.templateoverride.register();	
	});
}

function RegisterInMDS() {
	/* RegisterContext override for MDS enabled site */
	RegisterModuleInit(_spPageContextInfo.siteServerRelativeUrl + "/_catalogs/masterpage/Display Templates/news-post-summary.js", RegisterContext);

	/* RegisterContext override for MDS disabled site (because we need to call the entry point function in this case whereas it is not needed for anonymous functions) */
	RegisterContext();
}

if (typeof (RegisterModuleInit) == "function" && typeof _spPageContextInfo != "undefined" && _spPageContextInfo != null) {
	RegisterInMDS();
} else {
	RegisterContext();
}

})();


