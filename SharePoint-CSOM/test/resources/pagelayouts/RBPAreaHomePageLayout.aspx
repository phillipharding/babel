<%@ Page language="C#" Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="RBNews" Namespace="RB.Buzz.WebControls.News" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>
<%@ Register TagPrefix="RBNav" Namespace="RB.Buzz.WebControls.Navigation" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>
<%@ Register TagPrefix="RBMisc" Namespace="RB.Buzz.WebControls.Misc" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>
<asp:Content ContentPlaceholderID="PlaceHolderAdditionalPageHead" runat="server">
	<SharePointWebControls:UIVersionedContent UIVersion="3" runat="server">
		<ContentTemplate>
			<style type="text/css">
				Div.ms-titleareaframe {
					height: 100%;
				}
				.ms-pagetitleareaframe table {
					background: none;
				}
			</style>
		</ContentTemplate>
	</SharePointWebControls:UIVersionedContent>
	<SharePointWebControls:UIVersionedContent UIVersion="4" runat="server">
		<ContentTemplate>
			<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/page-layouts-21.css %>" runat="server"/>
			<PublishingWebControls:EditModePanel runat="server">
				<!-- Styles for edit mode only-->
				<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/edit-mode-21.css %>"
					After="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/page-layouts-21.css %>" runat="server"/>
			</PublishingWebControls:EditModePanel>
		</ContentTemplate>
	</SharePointWebControls:UIVersionedContent>
  <PublishingWebControls:EditModePanel runat="server" id="EditModePanelEdit" PageDisplayMode="Edit">
    <style type="text/css">
     .head .announcements span div span, 
     .head .calendar span div span,
     .head .leadership span div span,
     .head .news span div span,
     .head .principles span div span,
     .head .rules span div span{
     	background-image: none;
     	padding-top: 0px;
     	padding-left: 0px;
     	margin-top: -10px;
     	margin-left: -10px;
     }
     .head .announcements span div span input, 
     .head .calendar span div span input,
     .head .leadership span div span input,
     .head .news span div span input,
     .head .principles span div span input,
     .head .rules span div span input {
     	height: 20px;
     }
     .ms-formfieldlabelcontainer {
     	display: none;
     	visibility: hidden;
     }
    </style>
  </PublishingWebControls:EditModePanel>
  
  <link rel="stylesheet" type="text/css" href="/sites/RBPNA/SiteAssets/ArchiveLink.css" /> 
  <link rel="stylesheet" type="text/css" href="/sites/RBPNA/SiteAssets/AnnouncementsArchiveLink.css" /> 

  
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitle" runat="server">
	<SharePointWebControls:UIVersionedContent UIVersion="3" runat="server">
		<ContentTemplate>
			<SharePointWebControls:ListProperty Property="Title" runat="server"/> 
			- <SharePointWebControls:ListItemProperty Property="BaseName" MaxLength=40 runat="server"/>
		</ContentTemplate>
	</SharePointWebControls:UIVersionedContent>
	<SharePointWebControls:UIVersionedContent UIVersion="4" runat="server">
		<ContentTemplate>
			<SharePointWebControls:ListProperty Property="Title" runat="server"/> 
			- <SharePointWebControls:FieldValue FieldName="Title" runat="server"/>
		</ContentTemplate>
	</SharePointWebControls:UIVersionedContent>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitleInTitleArea" runat="server">
	<asp:ScriptManagerProxy runat="server" id="ScriptManagerProxy">
	</asp:ScriptManagerProxy>
	<SharePointWebControls:VersionedPlaceHolder UIVersion="3" runat="server">
		<ContentTemplate>
			<WebPartPages:WebPartZone runat="server" Title="loc:TitleBar" ID="TitleBar" AllowLayoutChange="false" AllowPersonalization="false"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
		</ContentTemplate>
	</SharePointWebControls:VersionedPlaceHolder>
	<SharePointWebControls:UIVersionedContent UIVersion="4" runat="server">
		<ContentTemplate>
			<SharePointWebControls:FieldValue FieldName="Title" runat="server" />
		</ContentTemplate>
	</SharePointWebControls:UIVersionedContent>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderTitleBreadcrumb" runat="server"> 
	<SharePointWebControls:VersionedPlaceHolder UIVersion="3" runat="server"> <ContentTemplate> <asp:SiteMapPath ID="siteMapPath" runat="server" SiteMapProvider="CurrentNavigation" RenderCurrentNodeAsLink="false" SkipLinkText="" CurrentNodeStyle-CssClass="current" NodeStyle-CssClass="ms-sitemapdirectional"/> </ContentTemplate> </SharePointWebControls:VersionedPlaceHolder> 
	<SharePointWebControls:UIVersionedContent UIVersion="4" runat="server"> <ContentTemplate> <SharePointWebControls:ListSiteMapPath runat="server" SiteMapProviders="CurrentNavigation" RenderCurrentNodeAsLink="false" PathSeparator="" CssClass="s4-breadcrumb" NodeStyle-CssClass="s4-breadcrumbNode" CurrentNodeStyle-CssClass="s4-breadcrumbCurrentNode" RootNodeStyle-CssClass="s4-breadcrumbRootNode" NodeImageOffsetX=0 NodeImageOffsetY=353 NodeImageWidth=16 NodeImageHeight=16 NodeImageUrl="/_layouts/images/fgimg.png" HideInteriorRootNodes="true" SkipLinkText="" /> </ContentTemplate> </SharePointWebControls:UIVersionedContent> </asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageDescription" runat="server">
	<SharePointWebControls:ProjectProperty Property="Description" runat="server"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderBodyRightMargin" runat="server">
	<div height=100% class="ms-pagemargin"><IMG SRC="/_layouts/images/blank.gif" width=10 height=1 alt=""></div>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
	<WebPartPages:SPProxyWebPartManager runat="server" id="spproxywebpartmanager"></WebPartPages:SPProxyWebPartManager>
	<p>&nbsp;</p>
	   <div class="rb_wrapper"><!-- Wrapper Start -->

			<div class="rbp_3g2">
				<div class="pod" id="news">
					<div class="head">
						<div class="news">
							<span>
							<SharePointWebControls:TextField FieldName="RB_RBP_BannerText1" runat="server"></SharePointWebControls:TextField></span></div>
					</div>
					<div class="body">
						<RBNews:NewsRotatorWebPart ID="NewsRotatorWebPart" runat="server" spWeb="RBP/News" __WebPartId="{AD9B8320-B2C5-44CB-9047-C063D506679D}"></RBNews:NewsRotatorWebPart>
					
					<div id="ArchiveDiv">
								<h3>
									<SharePointWebControls:SPLinkButton runat="server" NavigateUrl="~sitecollection/news/">
									Full Archive</SharePointWebControls:SPLinkButton>
								</h3>
						</div>
					
					</div>
				</div>
			</div>
			<div class="rbp_3g1">
				<div class="pod">
					<div class="head">
						<div class="leadership">
							<span>
							<SharePointWebControls:TextField FieldName="RB_RBP_BannerText2" runat="server"></SharePointWebControls:TextField></span></div>
					</div>
					<div class="body">
						<div class="content">
						 <WebPartPages:WebPartZone runat="server" FrameType="None" ID="LeadershipZone" Name="LeadershipZone" Title="Leadership Zone"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
						</div>
					</div>
				</div>
			</div>
			<div class="rbp_3g2">
				<div class="pod">
					<div class="head">
						<div class="announcements">
							<span>
							<SharePointWebControls:TextField FieldName="RB_RBP_BannerText3" runat="server"></SharePointWebControls:TextField></span></div>
					</div>
					<div class="body">
						<RBNews:AnnouncementsWebPart ID="AnnouncementsWebPart" runat="server" ListName="Announcements" __WebPartId="{7CEE6B71-81A9-4589-9D57-AE605AE2324D}"></RBNews:AnnouncementsWebPart>
					<div id="AnnouncementsArchiveDiv">
								<h3>
									<SharePointWebControls:SPLinkButton runat="server" NavigateUrl="~sitecollection/news/Pages/announcements.aspx">
									Full Archive</SharePointWebControls:SPLinkButton>
								</h3>
						</div>

					
					</div>
				</div>
			</div>

			<div class="rbp_3g1">
			  <div class="search">
				<div class="searchbox"><input type="text" placeholder="Search" /><a href="#" class="searchbtn">Search</a></div>
				<div class="searchbox"><input type="text" placeholder="Find a person" /><a href="#" class="psearchbtn">Search</a></div>
			  </div>
			  <RBNav:LinksWebPart runat="server" ID="LinksWebPart" Title="Links" __WebPartId="{547030BD-46E2-4D4A-AA57-FA31E5D7CB9D}"></RBNav:LinksWebPart>
			</div>

			<div class="rbp_3g3">
				<div class="pod">
					<div class="head">
						<div class="calendar">
							<span>
							<SharePointWebControls:TextField FieldName="RB_RBP_BannerText6" runat="server"></SharePointWebControls:TextField></span></div>
					</div>
					<div class="body">
						<div class="content">
							<WebPartPages:WebPartZone runat="server" FrameType="None" ID="Calendar" Name="Calendar" Title="Calendar Zone"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
						</div>
					</div>
				</div>
			</div>
	   </div><!-- Wrapper End -->
<script type="text/javascript" src="/Style Library/RBPv2/scripts/RBPSearch.js"></script>
  
	<SharePointWebControls:UIVersionedContent UIVersion="4" runat="server">
		<ContentTemplate>
			<div class="welcome blank-wp">
				<PublishingWebControls:EditModePanel runat="server" CssClass="edit-mode-panel">
					<SharePointWebControls:TextField runat="server" FieldName="Title" />
				</PublishingWebControls:EditModePanel>
				<div class="welcome-content">
					<PublishingWebControls:RichHtmlField FieldName="PublishingPageContent" HasInitialFocus="True" MinimumEditHeight="400px" runat="server"/>
				</div>
		</ContentTemplate>
	</SharePointWebControls:UIVersionedContent>
	<table cellpadding="4" cellspacing="0" border="0" width="100%">
		<SharePointWebControls:UIVersionedContent UIVersion="3" runat="server">
			<ContentTemplate>
				<tbody>
				<tr>
					<td valign="top" style="padding:0" colspan="3" width="100%">
						<PublishingWebControls:RichHtmlField id="PageContent" FieldName="PublishingPageContent" runat="server"/>
					</td>
				</tr>
			</ContentTemplate>
		</SharePointWebControls:UIVersionedContent>
		<tr>
			<td valign="top" style="padding:0">
				<table cellpadding="4" cellspacing="0" border="0" width="100%" height="100%">
					<tr>
						<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" colspan="3" valign="top"> 
						<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_Header%>" ID="Header"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
					</tr>
					<tr>
						<td width="100%" colspan="3" valign="top" style="padding:0">
							<table cellpadding="4" cellspacing="0" width="100%" height="100%">
								<tr>
									<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top"> 
									<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_TopLeft%>" ID="TopLeftRow"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
																	<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top"> 
																	<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_TopRight%>" ID="TopRightRow"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
								</tr>
							</table>
						</td>
					</tr>							<tr>
						<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" height="100%"> 
						<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_CenterLeft%>" ID="CenterLeftColumn"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
						<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" height="100%"> 
						<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_Center%>" ID="CenterColumn"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
						<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" height="100%"> 
						<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_CenterRight%>" ID="CenterRightColumn"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
					</tr>
					<tr>
						<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" colspan="3" valign="top"> 
						<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_Footer%>" ID="Footer"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
					</tr>
				</table>
			</td>
			<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" height="100%"> 
			<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_Right%>" ID="RightColumn" Orientation="Vertical"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
		</tr>
		<script language="javascript">if(typeof(MSOLayout_MakeInvisibleIfEmpty) == "function") {MSOLayout_MakeInvisibleIfEmpty();}</script>
	</table>
	<SharePointWebControls:UIVersionedContent UIVersion="4" runat="server">
		<ContentTemplate>
			</div>
		</ContentTemplate>
	</SharePointWebControls:UIVersionedContent>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderAdditional" runat="server">
		<div class="rb_lw">
	 </div>	 
	 <div class="rb_1w">
	 </div>	 
</asp:Content>