<%@ Page language="C#" Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Nav" Namespace="RB.Buzz.WebControls.Navigation" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>
<asp:Content ContentPlaceholderID="PlaceHolderAdditionalPageHead" runat="server">
	<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/page-layouts-21.css %>" runat="server"/>
	<PublishingWebControls:EditModePanel runat="server">
		<!-- Styles for edit mode only-->
		<SharePointWebControls:CssRegistration name="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/edit-mode-21.css %>"
			After="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/page-layouts-21.css %>" runat="server"/>
	</PublishingWebControls:EditModePanel>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageTitle" runat="server">
<SharePointWebControls:ListProperty Property="Title" runat="server"/> - 
<SharePointWebControls:FieldValue FieldName="Title" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageTitleInTitleArea" runat="server">
	<SharePointWebControls:FieldValue FieldName="Title" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderTitleBreadcrumb" runat="server"> 
	<SharePointWebControls:ListSiteMapPath runat="server" SiteMapProviders="CurrentNavigation" RenderCurrentNodeAsLink="false" PathSeparator="" CssClass="s4-breadcrumb" NodeStyle-CssClass="s4-breadcrumbNode" CurrentNodeStyle-CssClass="s4-breadcrumbCurrentNode" RootNodeStyle-CssClass="s4-breadcrumbRootNode" NodeImageOffsetX=0 NodeImageOffsetY=353 NodeImageWidth=16 NodeImageHeight=16 NodeImageUrl="/_layouts/images/fgimg.png" HideInteriorRootNodes="true" SkipLinkText=""/>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageDescription" runat="server">
	<SharePointWebControls:ProjectProperty Property="Description" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderBodyRightMargin" runat="server">
	<div height=100% class="ms-pagemargin"><IMG SRC="/_layouts/images/blank.gif" width=10 height=1 alt=""></div>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
	<link rel="stylesheet" href="/sites/fox/Style%20Library/RBPHRWebPartPageLayout.css" type="text/css" />

	<PublishingWebControls:EditModePanel runat="server" id="EditModePanelEdit" PageDisplayMode="Edit">
		<link rel="stylesheet" href="/sites/fox/Style%20Library/RBPHRWebPartPageLayout-edit.css" type="text/css" />

		<div>
			<SharePointWebControls:TextField runat="server" FieldName="Title" />
		</div>
</PublishingWebControls:EditModePanel>
  <p>&nbsp;</p>
  <div class="rb_wrapper"><!-- Wrapper Start -->
    <div id="rb_breadcrumb">
		<Nav:BreadcrumbControl runat="server" ID="BreadcrumbControl"></Nav:BreadcrumbControl></div>
    <p>&nbsp;</p>
    <div class="rbp_3g3">
      <div class="pod">
        <div class="body">
          <div class="pane wide">
				  <PublishingWebControls:RichHtmlField FieldName="PublishingPageContent" DisableInputFieldLabel="True" HasInitialFocus="True" runat="server"/>
		        <div class="wpzone">
						<table cellpadding="4" cellspacing="0" border="0" width="100%">
							<tr>
								<td class="full last" id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top">
									<WebPartPages:WebPartZone runat="server" Title="Top Stripe" ID="TopStripe"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
								</td>
							</tr>
							<tr>
								<td class="full last" id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top">
									<WebPartPages:WebPartZone runat="server" Title="Sub Stripe" ID="SubStripe"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
								</td>
							</tr>
							<tr>
								<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top">
									<table cellpadding="4" cellspacing="0" border="0" width="100%" height="100%">
										<tr>
											<td class="thirds" id="" name="" valign="top" width="33%" height="100%"> 
												<WebPartPages:WebPartZone runat="server" Title="Mid Column 1" ID="MidColumn1"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
											</td>
											<td class="thirds" id="" name="" valign="top" width="33%" height="100%"> 
												<WebPartPages:WebPartZone runat="server" Title="Mid Column 2" ID="MidColumn2"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
											</td>
											<td class="thirds last" id="" name="" valign="top" width="33%" height="100%"> 
												<WebPartPages:WebPartZone runat="server" Title="Mid Column 3" ID="MidColumn3"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top">
									<table cellpadding="4" cellspacing="0" border="0" width="100%" height="100%">
										<tr>
											<td class="halfs" id="" name="" valign="top" width="50%" height="100%"> 
												<WebPartPages:WebPartZone runat="server" Title="BottomColumn 1" ID="BottomColumn1"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
											</td>
											<td class="halfs last" id="" name="" valign="top" width="50%" height="100%"> 
												<WebPartPages:WebPartZone runat="server" Title="Bottom Column 2" ID="BottomColumn2"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
		        </div>
          </div>
        </div>
      </div>
    </div>
  </div><!-- Wrapper End -->
  <script type="text/javascript">
  		if (typeof (MSOLayout_MakeInvisibleIfEmpty) == "function") { 
  			MSOLayout_MakeInvisibleIfEmpty();
  		}
  		$(function() {
  			/* hide empty page content wrapper DIV */
  			$(".pane > DIV.ms-rtestate-field:empty").remove();
  			$("IMG.ms-WPHeaderMenuImg").attr('src','/_layouts/images/downarrwwhite.png');
  		});
  	</script>
</asp:Content>
