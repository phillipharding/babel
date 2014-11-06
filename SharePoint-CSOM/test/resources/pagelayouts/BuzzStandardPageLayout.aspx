<%@ Page language="C#" Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Nav" Namespace="RB.Buzz.WebControls.Navigation" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>
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
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitle" runat="server">
	- <SharePointWebControls:FieldValue id="PageTitle" FieldName="Title" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageTitleInTitleArea" runat="server">
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderTitleBreadcrumb" runat="server"> 
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageDescription" runat="server">
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderBodyRightMargin" runat="server">
	<div height=100% class="ms-pagemargin"><IMG SRC="/_layouts/images/blank.gif" width=10 height=1 alt=""></div>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
<div class='rb_wrapper'>
   <div id="rb_breadcrumb">
		<Nav:BreadcrumbControl runat="server" ID="BreadcrumbControl"></Nav:BreadcrumbControl>
	</div>

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

</div>
</asp:Content>
