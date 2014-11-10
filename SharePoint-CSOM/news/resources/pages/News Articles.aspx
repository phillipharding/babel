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
	<div class='posts-navigator container pure-g'>
		<div class='pure-u-1'>
			<SharePoint:SPSecurityTrimmedControl runat="server" permission="AddAndCustomizePages">
				<table id="Hero-WPQ2" class="add-a-new-post" dir="none" border="0" cellspacing="0" cellpadding="0">
					<tbody>
						<tr>
							<td class="ms-list-addnew ms-textXLarge ms-list-addnew-aligntop ms-soften">
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
		</div>
		<div class='pure-u-1'>
			<WebPartPages:WebPartZone runat="server" FrameType="TitleBarOnly" ID="BlogNavigator" Title="Navigator" AllowPersonalization="false" />
		</div>
	</div>
</asp:Content>

<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
	<div class='news-main-content container-maxwidth pure-g'>
		<div class='pure-u-1 pure-u-lg-3-4 pure-u-md-3-4 news-main-content-left'>
			<WebPartPages:WebPartZone runat="server" FrameType="TitleBarOnly" ID="Left" Title="Left" AllowPersonalization="false" />
		</div>
		<div class='pure-u-1 pure-u-lg-1-4 pure-u-md-1-4 news-main-content-right'>
			<WebPartPages:WebPartZone runat="server" FrameType="TitleBarOnly" ID="Right" Title="Right" AllowPersonalization="false" />
		</div>
	</div>
</asp:Content>
