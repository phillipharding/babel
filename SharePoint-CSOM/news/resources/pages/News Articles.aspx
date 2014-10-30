<%@ Page language="C#" MasterPageFile="~masterurl/default.master"    Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage,Microsoft.SharePoint,Version=15.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c"  %> <%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Import Namespace="Microsoft.SharePoint" %> <%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitle" runat="server">
	<SharePoint:EncodedLiteral runat="server" text="<%$Resources:wss,multipages_homelink_text%>" EncodeMethod='HtmlEncode'/> - <SharePoint:ProjectProperty Property="Title" runat="server"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitleInTitleArea" runat="server">
	<SharePoint:ProjectProperty Property="Title" runat="server"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderSearchArea" runat="server">
	<SharePoint:DelegateControl runat="server" ControlId="SmallSearchInputBox" />
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderLeftNavBar" runat="server">
	<div class='posts-navigator'>
		<SharePoint:SPSecurityTrimmedControl runat="server" permission="AddAndCustomizePages">
			<table id="Hero-WPQ2" class="add-a-new-post" dir="none" border="0" cellspacing="0" cellpadding="0">
				<tbody>
					<tr>
						<td class="ms-list-addnew ms-textXLarge ms-list-addnew-aligntop ms-soften">
							<!-- sitecollection = "{{~sitecollection}}/something"   -->
							<a title="Add a new item to this list or library." class="ms-heroCommandLink ms-hero-command-enabled-alt" id="idHomePageNewItem" onclick='_EasyUploadOrNewItem2(event, false, "{{~site}}/Lists/Posts/NewPost.aspx?Source={{~site}}&amp;RootFolder=", "WPQ2"); return false;' href="{{~site}}/Lists/Posts/NewPost.aspx?Source={{~site}}&amp;RootFolder=" target="_self">
								<span class="ms-list-addnew-imgSpan20">
									<img class="ms-list-addnew-img20" id="idHomePageNewItem-img" src="/_layouts/15/images/spcommon.png?rev=38">
								</span>
								<span>New Article</span>
							</a>
						</td>
					</tr>
				</tbody>
			</table>
		</SharePoint:SPSecurityTrimmedControl>
		<WebPartPages:WebPartZone runat="server" FrameType="TitleBarOnly" ID="BlogNavigator" Title="Navigator" AllowPersonalization="false" />
	</div>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderBodyAreaClass" runat="server">
	<SharePoint:StyleBlock runat="server">
	.ms-bodyareaframe {
		padding: 0px;
	}
	</SharePoint:StyleBlock>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
	<table id="MSO_ContentTable" MsoPnlId="layout" cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
		 <td>
		  <table cellpadding="0" cellspacing="0" class="ms-blog-MainArea">
		   <tr>
			<td valign="top">
				<WebPartPages:WebPartZone runat="server" FrameType="TitleBarOnly" ID="Left" Title="Left" AllowPersonalization="false" />
			</td>
			<td valign="top" class="ms-blog-LeftColumn">
				<WebPartPages:WebPartZone runat="server" FrameType="TitleBarOnly" ID="Right" Title="Right" AllowPersonalization="false" />
			</td>
		  </tr>
		 </table>
		</td>
	   </tr>
	</table>
</asp:Content>
