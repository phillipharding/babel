(function() {
/*
	CSR display template
	JSLink = ~sitecollection/_catalogs/masterpage/Display Templates/news-post-summary.js
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
			Header: HeaderRender,
			Footer: FooterRender,
			Item: ItemRender,
			Fields: {
				'Body': {'View': FieldBodyViewRender }
			}
		},
		OnPostRender: OnPostRender/*,
		ListTemplateType: 301,
		BaseViewID: 0*/
	};

	function FieldBodyViewRender(ctx) {
		console.log(String.format(">>In FieldBodyViewRender -2, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		var ret = "<hr/><hr/>" + ctx.CurrentItem.Body;
		return ret;
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


