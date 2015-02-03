<%@ Page language="C#"   Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=16.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<asp:Content ContentPlaceholderID="PlaceHolderAdditionalPageHead" runat="server">
	<SharePointWebControls:ScriptBlock runat="server">
	</SharePointWebControls:ScriptBlock>
	<SharePointWebControls:StyleBlock runat="server">
		.buzzwidepage-sidebar { margin-bottom: -20px; }
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

<asp:Content ContentPlaceholderID="PlaceHolderPageImage" runat="server">
   <SharePoint:SPSimpleSiteLink runat="server" id="PageTitleInTitleAreaSiteLink">
       <span class='PlaceHolderPageImage'>
           <i class="fa fa-file-text-o"></i>
       </span>
   </SharePoint:SPSimpleSiteLink>
</asp:Content>

<asp:Content ContentPlaceholderID="PlaceHolderQuickLaunchBottom" runat="server">
	<div class="ms-core-listMenu-verticalBox buzzwidepage-sidebar">
		<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="Sidebar" FrameType="TitleBarOnly" Title="Sidebar" Orientation="Vertical" />
	</div>
	<SharePoint:SPSecurityTrimmedControl runat="server" permission="ViewFormPages">
		<div class="ms-core-listMenu-verticalBox">
			<a href='<asp:Literal Text="<% $SPUrl:~site/_layouts/15/viewlsts.aspx %>" runat="server" />' class="ms-core-listMenu-item ms-core-listMenu-heading" title='<asp:Literal Text="<%$Resources:wss,AllSiteContentMore%>" runat="server" />' accesskey="3" id="idNavLinkViewAll">
				<span class="ms-splinkbutton-text"><i class="fa fa-th-large"></i>&nbsp;&nbsp;<asp:Literal Text="<%$Resources:wss,AllSiteContentMore%>" runat="server" /></span>
			</a>
		</div>
	</SharePoint:SPSecurityTrimmedControl>
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
				<div class='pure-u-1'>
					<div class='web-part'>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="Header" FrameType="TitleBarOnly" Title="Header" Orientation="Vertical" />
					</div>
				</div>
				<div class='pure-u-1'>
					<div class='page-content'>
						<PublishingWebControls:RichHtmlField FieldName="PublishingPageContent" HasInitialFocus="True" MinimumEditHeight="400px" runat="server" />
					</div>
				</div>
				<div class='pure-u-1'>
					<div class='web-part'>
						<WebPartPages:WebPartZone runat="server" AllowPersonalization="false" ID="Footer" FrameType="TitleBarOnly" Title="Footer" Orientation="Vertical" />
					</div>
				</div>
			</div>
		</section>
	</div>
</asp:Content>


