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
	</SharePointWebControls:StyleBlock>
	
	<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Themable/Core Styles/pagelayouts15.css %>" runat="server"/>
	<PublishingWebControls:EditModePanel runat="server" id="editmodestyles">
		<!-- Styles for edit mode only-->
		<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Themable/Core Styles/editmode15.css %>"
			After="<% $SPUrl:~sitecollection/Style Library/~language/Themable/Core Styles/pagelayouts15.css %>" runat="server"/>
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
</asp:Content>


