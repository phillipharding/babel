(function() {

/*
	/_layouts/15/sp.ui.blogs.js
	~sitecollection/_catalogs/masterpage/Display Templates/news-csr.js
	~sitecollection/_layouts/15/sp.init.js|~sitecollection/_catalogs/masterpage/Display Templates/news-csr.js

	ctx.ListData.PrevHref = '?&&p_PublishedDate=20141010%2017%3a00%3a00&&PageFirstRow=1&&View=c71bee3e-7d29-42eb-88cd-9a2ddf89dd00'
	ctx.ListData.NextHref = '?Paged=TRUE&p_PublishedDate=20141013%2010%3a00%3a00&p_ID=10&PageFirstRow=6&&View=c71bee3e-7d29-42eb-88cd-9a2ddf89dd00'

	BaseViewID
		0: Summary View
		7: Post.aspx view
		9: Date.aspx view
		8: Category.aspx view

*/
window.RBNews = window.RBNews || { ViewIDs: { Summary: 0, Post: 7, Date: 9, Category: 8 } };

RBNews.EditCommand = function RBNews_EditCommand(elemid, editurl) {
    RBNews.EditCommand.initializeBase(this, ['edit_' + elemid, Strings.STS.L_SPBlogsEditCommand]);
    this.$EditUrl = editurl;
};
RBNews.EditCommand.prototype = {
    $EditUrl: null,
    get_href: function RBNews_EditCommand$get_href() {
        return this.$EditUrl;
    },
    onClick: function RBNews_EditCommand$onClick() {
        STSNavigate(this.get_href());
    }
};
RBNews.EditCommand.registerClass('RBNews.EditCommand', SP.UI.Command);

RBNews.ShareCommand = function News_ShareCommand(elemid, url, linktext) {
    RBNews.ShareCommand.initializeBase(this, ['share_' + elemid, Strings.STS.L_SPBlogsShareCommand]);
    this.$Url = escapeProperlyCore(url, true);
    this.$LinkText = linktext;
};
RBNews.ShareCommand.click = function News_ShareCommand$$Click($p0, $p1) {
    window.location.href = 'mailto:?body=' + escapeProperlyCore($p0, false) + '&subject=' + escapeProperlyCore($p1, false);
};
RBNews.ShareCommand.prototype = {
    $Url: null,
    $LinkText: null,
    onClick: function News_ShareCommand$onClick() {
        RBNews.ShareCommand.click(this.$Url, this.$LinkText);
    }
};
RBNews.ShareCommand.registerClass('RBNews.ShareCommand', SP.UI.Command);

RBNews.FieldRendererCommand = function News_FieldRendererCommand(fieldName, elemid, ctx) {
    RBNews.FieldRendererCommand.initializeBase(this, ['', '']);
    this.$elementId = elemid;
    this.$ctx = ctx;
    this.$fieldName = fieldName;
};
RBNews.FieldRendererCommand.prototype = {
    $J_1: null,
    $elementId: null,
    $ctx: null,
    $fieldName: null,
    get_linkElement: function News_FieldRendererCommand$get_linkElement() {
        if (!this.$J_1) {
            this.$J_1 = $get(this.$elementId);
        }
        return this.$J_1;
    },
    render: function News_FieldRendererCommand$render($hb) {
        $hb.addCssClass('ms-comm-cmdSpaceListItem');
        $hb.renderBeginTag('span');
        $hb.write(spMgr.RenderFieldByName(this.$ctx, this.$fieldName, this.$ctx.CurrentItem, this.$ctx.ListSchema));
        $hb.renderEndTag();
    }
};
RBNews.FieldRendererCommand.registerClass('RBNews.FieldRendererCommand', SP.UI.Command);

RBNews.TemplateOverride = function() {
	var
		_cmdBars = [],
		_config = {
			RootElementId: null,
			BaseViewID: null,
			PrevHref: null,
			NextHref: null,
			CategoryId: null,
			StartDateTime: null,
			EndDateTime: null,
			LMY: null
		},
		debug = false,
		ctxOverride = {}, 
		ctxSingleArticleOverride = {}, 
		module = {
			register: function() {
				SPClientTemplates.TemplateManager.RegisterTemplateOverrides(ctxSingleArticleOverride);
				SPClientTemplates.TemplateManager.RegisterTemplateOverrides(ctxOverride);
			}
		};
	ctxOverride = {
		OnPreRender: OnPreRender,
		Templates: {
			Header: HeaderRender,
			Footer: FooterRender,
			Item: debug ? ItemRenderDebug : ItemRender
		},
		OnPostRender: OnPostRender,
		ListTemplateType: 301
		/*BaseViewID: 0*/
	};
	ctxSingleArticleOverride = {
		OnPreRender: OnPreRender,
		Templates: {
			Fields: {
				'Title': {'View': FieldTitleViewRender },
				'Body': {'View': FieldBodyViewRender },
				'PublishedDate': {'View': FieldPublishedDateViewRender }
			}
		},
		ListTemplateType: 301,
		BaseViewID: 7
	};

	function console(msg) {
		if (!window.console) return;
		try { 
			window.console.log(msg); 
		}
		catch (e) {
		}
	}

	function OnPreRender(ctx) {
		console(String.format(">>In OnPreRender, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
	   var $v0 = SP.ScriptHelpers.getDocumentQueryPairs();
	   
		_config.BaseViewID = ctx.BaseViewID;
      _config.PrevHref = ctx.ListData['PrevHref'];
      _config.NextHref = ctx.ListData['NextHref'];
	
		if (_config.BaseViewID == 8) { /* category view */
		   _config.CategoryId = $v0['CategoryId'];

			if (!SP.ScriptHelpers.isNullOrUndefinedOrEmpty(_config.PrevHref)) {
				_config.PrevHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.PrevHref, 'CategoryId', _config.CategoryId);
				ctx.ListData['PrevHref'] = _config.PrevHref;
			}
			if (!SP.ScriptHelpers.isNullOrUndefinedOrEmpty(_config.NextHref)) {
				_config.NextHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.NextHref, 'CategoryId', _config.CategoryId);
				ctx.ListData['NextHref'] = _config.NextHref;
			}
		} else if (_config.BaseViewID == 9) { /* Date view */
		   _config.StartDateTime = $v0['StartDateTime'];
		   _config.EndDateTime = $v0['EndDateTime'];
		   _config.LMY = $v0['LMY'];

	      if (!SP.ScriptHelpers.isNullOrUndefined(_config.StartDateTime)) {
				_config.StartDateTime = unescapeProperly(_config.StartDateTime);
	      }
	      if (!SP.ScriptHelpers.isNullOrUndefined(_config.EndDateTime)) {
				_config.EndDateTime = unescapeProperly(_config.EndDateTime);
	      }
	      if (!SP.ScriptHelpers.isNullOrUndefined(_config.LMY)) {
				_config.LMY = unescapeProperly(_config.LMY);
	      }

			if (!SP.ScriptHelpers.isNullOrUndefinedOrEmpty(_config.PrevHref)) {
				_config.PrevHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.PrevHref, 'StartDateTime', _config.StartDateTime);
				_config.PrevHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.PrevHref, 'EndDateTime', _config.EndDateTime);
				_config.PrevHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.PrevHref, 'LMY', _config.LMY);
				ctx.ListData['PrevHref'] = _config.PrevHref;
			}
			if (!SP.ScriptHelpers.isNullOrUndefinedOrEmpty(_config.NextHref)) {
				_config.NextHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.NextHref, 'StartDateTime', _config.StartDateTime);
				_config.NextHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.NextHref, 'EndDateTime', _config.EndDateTime);
				_config.NextHref = SP.ScriptHelpers.replaceOrAddQueryString(_config.NextHref, 'LMY', _config.LMY);
				ctx.ListData['NextHref'] = _config.NextHref;
			}
		}
	}
	function HeaderRender(ctx) {
		console(String.format(">>In HeaderRender, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		
		_config.RootElementId = String.format("{0}_{1}", ctx.wpq, SP.UI.UIUtility.generateRandomElementId());
		return String.format("<div id='{0}' class='news-post-container'><ul class='pure-g'>", _config.RootElementId);
	}
	function FooterRender(ctx) {
		console(String.format(">>In FooterRender, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		return "</ul></div>";
	}
	function ItemRenderDebug(ctx, field, listItem, listSchema) {
		console(String.format(">>In ItemRenderDebug, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		var html = '<li>';
		for(var k in ctx.CurrentItem) {
			html += String.format("<div>{0} = [[{1}]]</div>", k, ctx.CurrentItem[k]);
		}
		html += "</li>"
		return html;
	}

	function getItemPostUrl(ctx) {
		var url = '';
		url = GlobalState.SPUIBlogs_blogsPostUrl.replace("{ID}", ctx.CurrentItem["ID"]);
		return url;
	}
	function getItemCategoryUrl(ctx, category) {
		var url = String.format("{0}/SitePages/Categories.aspx?CategoryId={{CategoryId}}", ctx.HttpRoot);
		url = url.replace("{CategoryId}", category['lookupId']);
		return url;
	}
	function renderItemNumComments(ctx, $nc, $h, $left) {
		$h.addCssClass($left ? 'ms-blog-command-noLeftPadding ms-textSmall' : 'ms-blog-command');
		$h.renderBeginTag('a');
		var $v1 = SP.Utilities.LocUtility.getLocalizedCountValue(Strings.STS.L_SPClientNumCommentsTemplate, Strings.STS.L_SPClientNumCommentsTemplateIntervals, Number.parseLocale($nc));
		$h.write(String.format($v1, $nc));
		$h.renderEndTag();
	}
	function renderItemCategories(ctx, categories) {
		var $v0 = new SP.HtmlBuilder();
		for (var $v1 = 0, $v2 = categories.length; $v1 < $v2; $v1++) {
			var 
				$category = categories[$v1],
				$url = getItemCategoryUrl(ctx, $category);
			$v0.addAttribute('class', 'news-post-item-category');
			$v0.renderBeginTag('span');
			$v0.addAttribute('href', $url);
			$v0.addAttribute('id', 'blgcat');
			$v0.addAttribute('class', 'ms-link');
			$v0.renderBeginTag('a');
			$v0.writeEncoded($category['lookupValue']);
			$v0.renderEndTag();
			$v0.renderEndTag();
		}
		return $v0.toString();
	}
	function ItemRender(ctx, field, listItem, listSchema) {
		console(String.format(">>In ItemRender, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		var
			html = [],
			$itemElemId = String.format("{0}_post_{1}", ctx.wpq, ctx.CurrentItem['ID']),
			$cmdItemElemId = String.format("{0}_cmd_{1}", ctx.wpq, ctx.CurrentItem['ID']);
		html.push(String.format("<li class='pure-u-1 pure-u-lg-1-2 pure-u-xl-1-2 news-post-item' id='{0}'><div class='box'>", $itemElemId));

		var
			postUrl = getItemPostUrl(ctx),
			author = spMgr.RenderFieldByName(ctx, 'Author', ctx.CurrentItem, ctx.ListSchema),
			postTime = spMgr.RenderFieldByName(ctx, 'PublishedDate.TimeOnly', ctx.CurrentItem, ctx.ListSchema)
			categories = ctx.CurrentItem["PostCategory"],
			categoriesHtml = renderItemCategories(ctx, categories),
			body = ctx.CurrentItem["Body"],
			newsPageImage = ctx.CurrentItem["NewsPageImage"];
		var
			d = new Date(ctx.CurrentItem["PublishedDate.ISO8601"]),
			newspostdate = String.format("<div class='news-post-item-date'><span class='date'>{0}</span><span class='month'>{1}</span></div>",
												d.getDate(), d.format('MMM'));

		if (!newsPageImage || !newsPageImage.length || !newsPageImage.match(/<img /gi)) {
			newsPageImage = String.format("<img src='{0}/SiteAssets/news/images/postdefault-image-kites.jpg' class='default' />", ctx.HttpRoot);
		}

		if (body && body.length) {
			body = body.replace(/\u200B/g,'');
		}
		if (_config.BaseViewID !== 7) {
			/* if not in POST view, then strip HTML and truncate the post copy */
			body = SP.ScriptHelpers.removeHtmlAndTrimStringWithEllipsis(body, 200);
			if (body && body.match(/[.]{3}$/g)) {
				/* copy was truncated, add the Read More link */
				body += String.format("<a class='news-post-readmore' href='{0}'>Read More</a>", postUrl);
			}
		}

		html.push(String.format("<div class='news-post-item-image'>{0}</div>", newsPageImage));
		html.push(String.format("<h2><a href='{0}'>{1}</a></h2>", postUrl, ctx.CurrentItem.Title));
		html.push(String.format("<div>By:&nbsp;{0}</div>", author));
		html.push(newspostdate);
		html.push(String.format("<div>At:&nbsp;{0}</div>", postTime));
		html.push(String.format("<div>In:&nbsp;{0}</div>", categoriesHtml));
		html.push(String.format("<div>{0}</div>", body));

		var $h = new SP.HtmlBuilder();
		var cmdBar = new SP.UI.CommandBar();
		$h.addCssClass('ms-blog-commandSpace');
		$h.renderBeginTag('div');

		/* Comand: comments */
		var $nc = ctx.CurrentItem['NumComments'];
		if (/*ctx.BaseViewID !== 7 &&*/ !SP.ScriptHelpers.isNullOrUndefined($nc)) {
		   $h.addAttribute('href', postUrl + '#comments');
		   $h.addCssClass('ms-comm-metalineItemSeparator');
		   renderItemNumComments(ctx, $nc, $h, true);
		   $h.addCssClass('ms-blog-command');
		   $h.addAttribute('style', 'display: inline-block;');
		}

		/* Comand: likes/ratings */
		var $v2 = ['LikesCount', 'AverageRating'];
		var $v3 = ['likesElement-', 'averageRatingElement-'];
		for (var $v6 = 0; $v6 < $v2.length; $v6++) {
		   if (SP.ScriptHelpers.getFieldFromSchema(ctx.ListSchema, $v2[$v6])) {
		       cmdBar.addCommand(new RBNews.FieldRendererCommand($v2[$v6], $v3[$v6] + ctx.CurrentItem['ID'], ctx));
		   }
		}
		/* Comand: share link */
		cmdBar.addCommand(new RBNews.ShareCommand($cmdItemElemId, postUrl, ctx.CurrentItem["Title"]));

		/* Comand: edit */
		var $v4 = SP.ScriptHelpers.getListLevelPermissionMask(ctx.CurrentItem);
		var $v5 = Number.parseInvariant(SP.ScriptHelpers.getUserFieldProperty(ctx.CurrentItem, 'Author', 'id'));
		if (ctx.CurrentUserId === $v5 && SP.ScriptHelpers.hasPermission($v4, 4) || SP.ScriptHelpers.hasPermission($v4, 2048)) {
		   var $v7 = SP.ScriptHelpers.replaceOrAddQueryString(ctx.editFormUrl, 'ID', ctx.CurrentItem['ID']);
		   var $v8 = window.self.ajaxNavigate;

		   $v7 = SP.ScriptHelpers.replaceOrAddQueryString($v7, 'Source', $v8.get_href());
		   cmdBar.addCommand(new  RBNews.EditCommand($cmdItemElemId, $v7));
		}
		/**/

		cmdBar.render($h);
		$h.renderEndTag();
		html.push($h.toString());

		_cmdBars.push(cmdBar);

		html.push('</div></li>');
		return html.join('').replace(/\u200B/g,'');;
	}
	function OnPostRender(ctx) {
		console(String.format(">>In OnPostRender, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));

		if (_cmdBars.length) {
			for(var i=0; i<_cmdBars.length; i++){
				_cmdBars[i].attachEvents();
			}
		}
	}

/* CTXSINGLEARTICLEOVERRIDE */
	function FieldTitleViewRender(ctx, field, listItem, listSchema) {
		console(String.format(">>In FieldTitleViewRender [{3}], List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType, ctx.CurrentItem.PublishedDate));
		/* close the <A/> and <H2/> tags first */

		var html = ["</a></h2>"];
		var
			postUrl = getItemPostUrl(ctx),
			author = spMgr.RenderFieldByName(ctx, 'Author', ctx.CurrentItem, ctx.ListSchema),
			postTime = spMgr.RenderFieldByName(ctx, 'PublishedDate.TimeOnly', ctx.CurrentItem, ctx.ListSchema)
			categories = ctx.CurrentItem["PostCategory"],
			categoriesHtml = renderItemCategories(ctx, categories),
			body = ctx.CurrentItem["Body"],
			newsPageImage = ctx.CurrentItem["NewsPageImage"];
		var
			d = new Date(ctx.CurrentItem["PublishedDate.ISO8601"]),
			newspostdate = String.format("<div class='news-post-item-date'><span class='date'>{0}</span><span class='month'>{1}</span></div>",
												d.getDate(), d.format('MMM'));

		if (!newsPageImage || !newsPageImage.length || !newsPageImage.match(/<img /gi)) {
			newsPageImage = String.format("<img src='{0}/SiteAssets/news/images/postdefault-image-kites.jpg' class='default' />", ctx.HttpRoot);
		}

		if (body && body.length) {
			body = body.replace(/\u200B/g,'');
		}

		html.push(String.format("<div class='news-post-item-image'>{0}</div>", newsPageImage));
		html.push(String.format("<div class='news-post-item-title'><h2>{0}</h2></div>", ctx.CurrentItem.Title));
		html.push(String.format("<div>By:&nbsp;{0}</div>", author));
		html.push(newspostdate);
		html.push(String.format("<div>At:&nbsp;{0}</div>", postTime));
		html.push(String.format("<div>In:&nbsp;{0}</div>", categoriesHtml));
		html.push(String.format("<div>{0}</div>", body));

		return html.join('').replace(/\u200B/g,'');;
	}
	function FieldPublishedDateViewRender(ctx, field, listItem, listSchema) {
		console(String.format(">>In FieldPublishedDateViewRender, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		var
			html = [''];
		return html.join('');
	}
	function FieldBodyViewRender(ctx, field, listItem, listSchema) {
		console(String.format(">>In FieldBodyViewRender, List={1} ListtemplateType={2} BaseViewID={0}", ctx.BaseViewID, ctx.ListTitle, ctx.ListTemplateType));
		var
			html = [''];
		return html.join('');
	}
/**/

	return module;
}();

function RegisterContext() {
	SP.SOD.executeFunc("clienttemplates.js", "SPClientTemplates", function() {
		RBNews.TemplateOverride.register();
	});		
	ExecuteOrDelayUntilScriptLoaded(function() {
		if (window.console) window.console.log('SP.INIT.JS loaded');
	}, 'SP.init.js');
}

function RegisterInMDS() {
	/* RegisterContext override for MDS enabled site */
	RegisterModuleInit(_spPageContextInfo.siteServerRelativeUrl + "/_catalogs/masterpage/Display Templates/news-csr.js", RegisterContext);
	RegisterContext();
}

if (typeof (RegisterModuleInit) == "function" && typeof _spPageContextInfo != "undefined" && _spPageContextInfo != null) {
	RegisterInMDS();
} else {
	RegisterContext();
}

})();


