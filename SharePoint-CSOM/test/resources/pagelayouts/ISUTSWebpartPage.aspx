<%@ Page language="C#"   Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="OSRVWC" Namespace="Microsoft.Office.Server.WebControls" Assembly="Microsoft.Office.Server, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="OSRVUPWC" Namespace="Microsoft.Office.Server.WebControls" Assembly="Microsoft.Office.Server.UserProfiles, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="SPSWC" Namespace="Microsoft.SharePoint.Portal.WebControls" Assembly="Microsoft.SharePoint.Portal, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="SEARCHWC" Namespace="Microsoft.Office.Server.Search.WebControls" Assembly="Microsoft.Office.Server.Search, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Nav" Namespace="RB.Buzz.WebControls.Navigation" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>

<asp:Content ContentPlaceHolderId="PlaceHolderAdditionalPageHead" runat="server">
	<SharePoint:CssRegistration ID="CssRegistration1" name="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/page-layouts-21.css %>" runat="server"/>
	<PublishingWebControls:EditModePanel runat="server" id="editmodestyles">
		<!-- Styles for edit mode only-->
		<SharePoint:CssRegistration ID="CssRegistration2" name="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/edit-mode-21.css %>"
			After="<% $SPUrl:~sitecollection/Style Library/~language/Core Styles/page-layouts-21.css %>" runat="server"/>
	</PublishingWebControls:EditModePanel>

	<style type="text/css">
		/* override RB styles */
		#rb_additional
		{
			margin-top: 10px;
			min-height: 20px;	
		}
		/* override webpart header */
		h3.ms-standardheader.ms-WPTitle
		{
		  color:rgb(60,90,108); 
		  text-transform:capitalize; 
		  font-family:Calibri, "Segoe UI", Verdana, Arial, sans-serif;
		  font-size:1.55em;
		}
		.ms-WPHeader TD
		{ border-bottom:1px dotted rgb(65,90,108); }

		#isutsWPPMain
		{
			padding: 5px 5px; 
			padding-right:0px; 
			position: absolute; 
			width:986px;
			margin: 0 5px;
		  /*background-color:rgb(234,235,238);*/
		}
		#rb_body #isutsWPPMain
		{
			/* override for RB styling */
			position: static; 
		}
		#isutsWPPMain .clear
		{ clear:both; }
		#isutsWPPHeader
		{ padding: 0 0; margin: 0 0; }
		#isutsWPPHeader .ms-pagebreadcrumb span[id$='PlaceHolderMain_ContentMap']
		{ padding-bottom:10px; display:block; }
		#isutsWPPRow1
		{ padding: 0 0; margin: 0 0; }
		#isutsWPPRow2
		{ padding: 0 0; margin: 0 0; padding-top:20px; }
		#isutsWPPRow1Left
		{ padding: 0 0; margin: 0 0; float:left; width:426px; }
		#isutsWPPRow1Left .caption
		{ padding-right:10px; }
		#isutsWPPRow1Right
		{ padding: 0 0; margin: 0 0; float:right; width:530px; }
		#isutsWPPRow2Left
		{ padding: 0 0; margin: 0 0; float:left; width:50%; }
		#isutsWPPRow2Right
		{ padding: 0 0; margin: 0 0; float:right; width:50%; }
		#isutsWPPRow2Left .box,
		#isutsWPPRow2Right .box
		{ padding:0px 0px; }
		#isutsWPPRow2Left .box
		{ padding-right:10px; }
		
		/* clearfix */
		#isutsWPPMain .group:before,
		#isutsWPPMain .group:after
		{ content: ""; display: table; }
		#isutsWPPMain .group:after
		{ clear: both; }
		#isutsWPPMain .group
		{ zoom: 1; /* For IE 6/7 (trigger hasLayout) */ }
	</style>
	<PublishingWebControls:EditModePanel ID="EditModePanel1" runat="server" PageDisplayMode="Edit">
		<style type="text/css">
			#isutsWPPMain
			{ width:auto; }
			#isutsWPPRow1Left
			{ width:380px; }
			#isutsWPPRow1Right
			{ float:left; }
			#isutsWPPRow2Left,
			#isutsWPPRow2Right
			{ float:left; width:44%; }
			.head { height: 66px; padding: 1px 0 0 0; }
			.head span { position:static; margin-left: 0; padding-left: 0; }
			.head .ms-long { width: 50%; font-size: 14pt; height: 25px; }
			.head .servicedesk span {
				background: none;
  				padding-left: 0px;
			}
		</style>
	</PublishingWebControls:EditModePanel>
</asp:Content>

<asp:Content ContentPlaceHolderID="PlaceHolderPageTitle" runat="server">
	- <SharePoint:FieldValue id="PageTitle" FieldName="Title" runat="server"/>
</asp:Content>

<asp:Content ContentPlaceHolderID="PlaceHolderPageTitleInTitleArea" runat="server">
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderPageImage" runat="server">
	<img src="/_layouts/images/blank.gif" alt="">
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderTitleBreadcrumb" runat="server"/>

<asp:Content ContentPlaceHolderID="PlaceHolderMain" runat="server">
<div class='rb_wrapper <SharePoint:FieldValue runat="server" FieldName="c79dba91-e60b-400e-973d-c6d06f192720" />'>
<!-- Wrapper Start -->
   <div id="rb_breadcrumb">
		<Nav:BreadcrumbControl runat="server" ID="BreadcrumbControl"></Nav:BreadcrumbControl>
	</div>

	<div id="isutsWPPMain">
		<div id="isutsWPPHeader">
			<table style="" border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="" valign="top">
						<PublishingWebControls:EditModePanel runat="server" PageDisplayMode="Edit">
							<SharePoint:TextField InputFieldLabel="Page CSS Class" FieldName="c79dba91-e60b-400e-973d-c6d06f192720" runat="server"></SharePoint:TextField>
							<SharePoint:TextField InputFieldLabel="Page Banner CSS Class" FieldName="7546ad0d-6c33-4501-b470-fb3003ca14ba" runat="server">
							</SharePoint:TextField>
						</PublishingWebControls:EditModePanel>

						<div class="head">
							<div class='<SharePoint:FieldValue FieldName="7546ad0d-6c33-4501-b470-fb3003ca14ba" runat="server" />'>
								<span>
								<SharePoint:NoteField InputFieldLabel="Page Banner Title" FieldName="9da97a8a-1da5-4a77-98d3-4bc10456e700" runat="server"></SharePoint:NoteField>
								</span>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<td style="" valign="top">
						<PublishingWebControls:RichImageField id="ImageField" FieldName="PublishingPageImage" runat="server"/>
					</td>
				</tr>
			</table>
		</div>
		
		<div id="isutsWPPRow1" class="group">
			<div id="isutsWPPRow1Left" style=''>
				<div class="caption">
					<PublishingWebControls:RichHtmlField id="Content" FieldName="PublishingPageContent" HasInitialFocus="True" MinimumEditHeight="400px" runat="server"/>
				</div>
			</div>	
			<div id="isutsWPPRow1Right" style=''>
				<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" FrameType="TitleBarOnly" ID="TopRight" 
						Title="Top Right" Orientation="Vertical" 
						QuickAdd-GroupNames="Default" QuickAdd-ShowListsAndLibraries="false"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
				
			</div>	
		</div>
		

		<div id="isutsWPPRow2" class="group">
			<div id="isutsWPPRow2Left" style=''>
				<div class="box">
					<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" FrameType="TitleBarOnly" ID="BottomLeft" 
							Title="Bottom Left" Orientation="Vertical" 
							QuickAdd-GroupNames="Default" QuickAdd-ShowListsAndLibraries="false"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
				</div>
				
			</div>	
			<div id="isutsWPPRow2Right" style=''>
				<div class="box">
					<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" FrameType="TitleBarOnly" ID="BottomRight" 
							Title="Bottom Right" Orientation="Vertical" 
							QuickAdd-GroupNames="Default" QuickAdd-ShowListsAndLibraries="false"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
				</div>				
			</div>	
		</div>

	</div>
       </div>
</asp:Content>
