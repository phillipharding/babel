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
	<style type="text/css">
		.rb_wrapper .pane {
		  padding-top: 0px;
		}
		.rb_wrapper .pane DIV.ms-rtestate-field {
			padding-top: 10px;
			display: block!important;	
		}
		.rb_wrapper .pane > DIV.ms-rtestate-field:empty {
			display: none!important;	
		}
		.rb_wrapper .pane .wpzone .s4-wpTopTable {
		    padding-right: 2px;
		}
		.rb_wrapper .pane .wpzone TD.last .s4-wpTopTable {
		    padding-right: 0px;
		}
		
		.rb_wrapper .pane .wpzone .s4-wpcell-plain {
		    padding-right: 2px;
		}
		.rb_wrapper .pane .wpzone TD.last .s4-wpcell-plain {
		    padding-right: 0px;
		}

		.ms-wpContentDivSpace {
		    margin-left: 0px;
		    margin-right: 0px;
		}
	</style>
	<PublishingWebControls:EditModePanel runat="server" id="EditModePanelEdit" PageDisplayMode="Edit">
	<style type="text/css">
		.rb_wrapper .pane > DIV.ms-rtestate-field {
			padding: 10px;
			border: 2px dashed #aaa;	
		}
		.EditOnly {
			display: block;
			font-weight: bold;
			text-decoration: underline;
			font-size: 18px;
		}
		#pol_eng,
		#pol_de,
		#pol_it,
		#pol_ru,
		#pol_ko,
		#pol_fr,
		#pol_es,
		#pol_lat,
		#pol_jp,
		#pol_thai,
		#pol_ch,
		#pol_arab,
		#pol_pol,
		#pol_hu,
		#pol_pt,
		#pol_tk,
		#pol_grk,
		#pol_cz,
		#pol_cr,
		#pol_hin,
		.wpzone {
			display: block;
		}
	</style>
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
        	<div style="width: 30%; float: right;">
			<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_CenterRight%>" ID="CenterRightColumn"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone></div>
          <div class="pane wide">
				  <PublishingWebControls:RichHtmlField FieldName="PublishingPageContent" DisableInputFieldLabel="True" HasInitialFocus="True" runat="server"/>
		        <div class="wpzone">
						<table cellpadding="4" cellspacing="0" border="0" width="100%">
							<tr>
								<td class="last" id="_invisibleIfEmpty" name="_invisibleIfEmpty" colspan="2" valign="top">
									<WebPartPages:WebPartZone runat="server" Title="Top Stripe" ID="TopStripe"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
								</td>
							</tr>
							<tr>
								<td valign="top" style="padding:0" width="70%">
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
										</tr>
										<tr>
											<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" height="100%"> 
											<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_CenterLeft%>" ID="CenterLeftColumn"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
											<td id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" height="100%"> 
											<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_Center%>" ID="CenterColumn"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
											<td class="last" id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" height="100%"> 
											<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_CenterRight%>" ID="CenterRightColumn"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
										</tr>
										<tr>
											<td class="last" id="_invisibleIfEmpty" name="_invisibleIfEmpty" colspan="3" valign="top"> 
											<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_Footer%>" ID="Footer"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
										</tr>
									</table>
								</td>
								<td class="last" id="_invisibleIfEmpty" name="_invisibleIfEmpty" valign="top" width="30%" height="100%"> 
								<WebPartPages:WebPartZone runat="server" Title="<%$Resources:cms,WebPartZoneTitle_Right%>" ID="RightColumn" Orientation="Vertical"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone> </td>
							</tr>
						</table>
		        </div>
          </div>
        </div>
      </div>
    </div>
  </div><!-- Wrapper End -->
  <script language="javascript">
  		if (typeof (MSOLayout_MakeInvisibleIfEmpty) == "function") { 
  			MSOLayout_MakeInvisibleIfEmpty();
  		}
  		$(function() {
  			/* hide empty page content wrapper DIV */
  			$(".pane > DIV.ms-rtestate-field:empty").remove();
  		});
  	</script>
</asp:Content>
