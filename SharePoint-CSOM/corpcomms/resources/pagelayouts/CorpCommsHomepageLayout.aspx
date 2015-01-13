<%@ Page language="C#"   Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=16.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<asp:Content ContentPlaceholderID="PlaceHolderAdditionalPageHead" runat="server">
	<SharePointWebControls:ScriptBlock runat="server">
		var g_Buzz365NoLeftNav = true;
	</SharePointWebControls:ScriptBlock>
	<SharePointWebControls:StyleBlock runat="server">
		/* ENSURE LEFT NAVIGATION IS HIDDEN (THIS PREVENTS A FOUC) */
		#sideNavBox-x {
			display:none!important;
		}
		#contentBox-x[class^='pure-u-'] {
			width: 100%!important;
		}
		
		/* HIDE PAGE TITLE IN TITLE AREA and RESIZE BREADCRUMB DIV */
		#pageTitle { display: none; }
		.ms-breadcrumb-box { height: 34px; }

		/* NEWS WEBPARTS FIXES */
		.news-control-newscarousel-wrapper .bx-wrapper {
			margin: 0 auto!important;
		}
		.news-control-newsbycategory-wrapper {
		  margin-right: 0!important;
		}

		/* TAB BLOCK */
		.tab-block {
		}
		.keyinformation .ms-rtestate-field ul,
		.keyinformation .ms-rtestate-field ol { 
			margin: 0 0 10px 0;
		}
		.keyinformation .ms-rtestate-field ul li { list-style-type: disc; }
		.keyinformation .ms-rtestate-field ol li { list-style-type: decimal; }
		.keyinformation .ms-rtestate-field li {
			margin: 5px 0 5px 30px; 
			padding: 2px 2px 2px 10px;
		}
		.keyinformation .ms-rtestate-field h3 { font-size: 1.4em; color: #EA3692; }
/* ==========================================================================
 Tabs
 ========================================================================== */
ul#tabs {
	list-style-type: none;
	padding: 0;
	font-size: 0px;
}

ul#tabs > li {
	text-transform: uppercase;
	width: 33.33%;
	font-size: 14px;
	height: 60px;
	display: inline-block;
	float: left;
	background-color: #B5BDC9;
	color: #fff;
	cursor: pointer;
	position: relative;
}
ul#tabs > li > div {
	height: 44px;
	padding: 10px;
	position: relative;
}
ul#tabs > li .fa { color: #41596B; }
ul#tabs > li h4 {
	color: #41596B;
	font-size: 1.2em;
	left: 55px;
	position: absolute;
	top: 50%;
	-webkit-transform: translateY(-50%);
	-moz-transform: translateY(-50%);
	-ms-transform: translateY(-50%);
	transform: translateY(-50%);
}

ul#tabs > li:hover {
	background-color: #41596B;
}

ul#tabs > li:hover .fa,
ul#tabs > li:hover h4 {
	color: #FFF;
}

ul#tabs > li.active {
	background-color: #CDD1D9;
}

ul#tabs > li.active:hover .fa,
ul#tabs > li.active:hover h4 {
	color: #41596B;
}

/* TAB CONTENT */
ul#tab {
	list-style-type: none;
	margin: 0px 0px 0px 0px;
	padding: 0;
}

ul#tab > li {
	display: none;
}

ul#tab > li.active {
	display: block;
	clear: both;
	margin-bottom: 20px;
}

ul#tab > li.tab-content {
	padding: 0 0 10px 0;
	background-color: #CDD1D9;
	float: left;
	width: 100%;
	color: #41596B;
}
ul#tab > li.tab-content .pure-g { padding-top: 10px; }
ul#tab > li.tab-content .pure-g.marg-r { margin-right: 10px; }
ul#tab > li.tab-content .pure-g.marg-l { margin-left: 10px; }

@media screen and (max-width: 480px) {
	ul#tabs > li h4 {
	  font-size: 1em;
	}
}

@media screen and (max-width: 360px) {
	ul#tabs > li h4 {
	  display: none;
	}
	ul#tabs > li .fa {
	  position: absolute;
	  left: 50%;
	  top: 50%;
	  -webkit-transform: translate(-50%, -50%);
	  -moz-transform: translate(-50%, -50%);
	  -ms-transform: translate(-50%, -50%);
	  transform: translate(-50%, -50%);
	}
}

@media screen and (max-width: 320px) {
}

	</SharePointWebControls:StyleBlock>
	
	<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Themable/Core Styles/pagelayouts15.css %>" runat="server"/>
	<PublishingWebControls:EditModePanel runat="server" id="editmodestyles">
		<!-- Styles for edit mode only-->
		<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Themable/Core Styles/editmode15.css %>"
			After="<% $SPUrl:~sitecollection/Style Library/~language/Themable/Core Styles/pagelayouts15.css %>" runat="server"/>

		<style type="text/css">
			ul#tab > li,
			ul#tab > li.active,
			ul#tab > li.tab-content {
				display: block;
				float: none;
				clear: both;
				margin-bottom: 20px;
			}
		</style>
	</PublishingWebControls:EditModePanel>
</asp:Content>

<asp:Content ContentPlaceholderID="PlaceHolderPageTitle" runat="server">
	<SharePointWebControls:FieldValue id="PageTitle" FieldName="Title" runat="server"/>
</asp:Content>
<asp:Content ContentPlaceholderID="PlaceHolderPageTitleInTitleArea" runat="server">
	<SharePointWebControls:FieldValue FieldName="Title" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceholderID="PlaceHolderMain" runat="server">
	<div class='cc-wrapper'>
		<PublishingWebControls:EditModePanel runat="server" CssClass="edit-mode-panel title-edit">
			<section class='cc-container'>
				<SharePointWebControls:TextField runat="server" FieldName="Title"/>
			</section>
		</PublishingWebControls:EditModePanel>
		<section class='cc-container cc-first-row'>
			<div class='pure-g'>
				<div class='pure-u-1 pure-u-md-2-3'>
					<div class='marg-r web-part'>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="HeaderLeft" FrameType="TitleBarOnly" Title="Header Left" Orientation="Vertical" />
					</div>
				</div>
				<div class='pure-u-1 pure-u-md-1-3'>
					<div class='web-part'>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="HeaderRight" FrameType="TitleBarOnly" Title="Header Right" Orientation="Vertical" />
					</div>
				</div>
			</div>
		</section>
		<section class='cc-container cc-second-row'>
			<div class='pure-g'>
				<div class='pure-u-1 pure-u-md-1-3'>
					<div class='marg-r web-part'>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="MiddleLeft" FrameType="TitleBarOnly" Title="Middle Left" Orientation="Vertical" />
					</div>
				</div>
				<div class='pure-u-1 pure-u-md-1-3'>
					<div class='marg-r web-part'>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="MiddleCenter" FrameType="TitleBarOnly" Title="Middle Center" Orientation="Vertical" />
					</div>
				</div>
				<div class='pure-u-1 pure-u-md-1-3'>
					<div class='web-part'>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="MiddleRight" FrameType="TitleBarOnly" Title="Middle Right" Orientation="Vertical" />
					</div>
				</div>
			</div>
		</section>
		<section class='cc-container cc-third-row'>
			<div class='pure-g'>
				<div class='pure-u-1 pure-u-md-1-2'>
					<div class='marg-r web-part'>
						<!-- Start :: Tab Block  -->
						<div class="tab-block">
							<ul id="tabs">
								<li class="active" title="Favourites">
									<div>
										<i class="fa fa-star fa-3x"></i> 
										<h4>Favourites</h4>
									</div>
								</li>
								<li title="Key Information">
									<div>
										<i class="fa fa-info-circle fa-3x"></i> 
										<h4>Key Information</h4>
									</div>
								</li>
								<li title="Calendar of Events">
									<div>
										<i class="fa fa-calendar fa-3x"></i>
										<h4>Events</h4>
									</div>
								</li>
							</ul>
							<ul id="tab">
								<li class="tab-content favourites active">
									<div class="pure-g marg-r marg-l">
										<div class="pure-u-1">
											<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="TabLeft" FrameType="TitleBarOnly" Title="Tab Left" Orientation="Vertical" />
										</div>
									</div>
								</li>
								<li class="tab-content keyinformation">
									<div class="pure-g marg-r marg-l">
										<div class="pure-u-1">
											<PublishingWebControls:RichHtmlField FieldName="PublishingPageContent" InputFieldLabel="Key Information" HasInitialFocus="False" MinimumEditHeight="200px" runat="server"/>
											<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="TabMiddle" FrameType="TitleBarOnly" Title="Tab Middle" Orientation="Vertical" />
										</div>
									</div>
								</li>
								<li class="tab-content calendarofevents">
									<div class="pure-g marg-r marg-l">
										<div class="pure-u-1">
											<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="TabRight" FrameType="TitleBarOnly" Title="Tab Right" Orientation="Vertical" />
										</div>
									</div>
								</li>
							</ul>
						</div>
						<!-- End :: Tab Block  -->
						<div class="ms-clear"></div>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="BottomLeft" FrameType="TitleBarOnly" Title="Bottom Left" Orientation="Vertical" />
					</div>
				</div>
				<div class='pure-u-1 pure-u-md-1-2'>
					<div class='pure-g'>
						<div class='pure-u-1 pure-u-sm-1-2'>
							<div class='marg-r web-part'>
								<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="BottomCenter" FrameType="TitleBarOnly" Title="Bottom Center" Orientation="Vertical" />
							</div>
						</div>
						<div class='pure-u-1 pure-u-sm-1-2'>
							<div class='web-part'>
								<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="BottomRight" FrameType="TitleBarOnly" Title="Bottom Right" Orientation="Vertical" />
							</div>
						</div>
					</div>
					<div class='pure-g'>
						<div class='pure-u-1'>
							<div class='web-part'>
								<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="Bottom" FrameType="TitleBarOnly" Title="Bottom" Orientation="Vertical" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</section>
	</div>

<script type="text/javascript">
(function($) {
"use strict";

$(function() {
	console.log(">>Init TABBLOCK");
	$("ul#tabs > li").click(function(e) {
		if (!$(this).hasClass("active")) {
			var tabNum = $(this).index();
			var nthChild = tabNum+1;
			$("ul#tabs > li.active").removeClass("active");
			$(this).addClass("active");
			$("ul#tab > li.active").removeClass("active");
			$("ul#tab > li:nth-child("+nthChild+")").addClass("active");
		}
	});
});

})(jQuery);

</script>

</asp:Content>


