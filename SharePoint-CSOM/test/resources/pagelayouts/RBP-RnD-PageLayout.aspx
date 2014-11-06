<%@ Page language="C#"   Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="RBNav" Namespace="RB.Buzz.WebControls.Navigation" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>
<%@ Register TagPrefix="RBNews" Namespace="RB.Buzz.WebControls.News" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>

<asp:Content ContentPlaceholderID="PlaceHolderPageTitle" runat="server">
	<SharePointWebControls:FieldValue id="PageTitle" FieldName="Title" runat="server"/>
</asp:Content>
<asp:Content ContentPlaceholderID="PlaceHolderMain" runat="server">
<div id="FullWidth" style="margin: 0 auto; width: 1200px;">
<WebPartPages:WebPartZone runat="server" Title="FullWidth" ID="FullWidth"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>
<WebPartPages:SPProxyWebPartManager runat="server" id="spproxywebpartmanager"></WebPartPages:SPProxyWebPartManager>
<table class="rb_wrapper" style="width: 1200px;">
	<tr>
		<td style="width:75%; vertical-align:top;">
			<table style="width:870px; ">
				<tr>
					<td id="tdWelcome" colspan="2" style="padding-right: 20px; width: 870px;">
						<div id="Zone1" style="margin-bottom:10px; width: 870px;">
							<div class="head">						
								<div class="Overview long">
									<h3 class="">Overview of Research &amp; 
									Development</h3>
								</div>
							</div>
							<WebPartPages:WebPartZone runat="server" Title="Top Stripe" ID="TopStripe"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-right: 20px; width: 870px;">
						<div style="margin-bottom:10px; width: 870px;">
							<div class="head">						
								<div class="News long">
									<h3 class="">R &amp; D News</h3>
								</div>
							</div>
							<WebPartPages:WebPartZone runat="server" Title="NewsRow" ID="NewsRow"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-right: 20px; width: 870px;">
						<div id="Zone2" style="margin-bottom:10px; width: 870px;">
							<div class="head">						
								<div class="Announcements long">
									<h3 class="">Announcements</h3>
								</div>
							</div>
							<WebPartPages:WebPartZone id="Middle" runat="server" title="Middle"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
				
							<tr>
								<td style="width: 415px; vertical-align:top; padding-right: 20px; width: 870px;">
									<div id="Spacing" class="SmallHeadIMG" style="margin-bottom:10px; width: 415px;">
										<div class="head">						
											<div class="Calendar short">
												<h3 class="">Calendar</h3>
											</div>
										</div>
										<WebPartPages:WebPartZone id="g_E8F2065587B146989FAB96A65FA9DEB8" runat="server" title="Zone 3"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
									</div>
								</td>
								<td style="width:415px; vertical-align:top; padding-right: 20px;">
									<div id="Spacing" class="SmallHeadIMG" style="margin-bottom:10px; margin-right: 0px; width: 415px;">
										<div class="head">						
											<div class="Stories">
												<h3 class="">ScienceDaily Top 
												Stories</h3>
											</div>
										</div>
										<WebPartPages:WebPartZone id="g_B7373E03BF5D4B54A0958F4035B81258" runat="server" title="Zone 7"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
									</div>
								</td>
							</tr>
						</div>
						<tr>
							<td colspan="2" style="width:870px; padding-right: 20px;">
								<div id="Spacing" style="margin-bottom:10px; width: 870px;">
									<WebPartPages:WebPartZone id="g_202EDEEB4698469C9741DC346EBC83CD" runat="server" title="Zone 8"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
								</div>
							</td>
						</tr>
					</td>
				</tr>
			</table>
		</td>
		<td style="width:25%; vertical-align:top;">
			<table style="width:100%">
				<tr>
					<td>
						<div id="Zone3" style="margin-bottom:10px; width: 100%;">
							<div class="head">						
								<div class="Mission short">
									<h3 class="">R&amp;D Mission</h3>
								</div>
							</div>
								<WebPartPages:WebPartZone id="TopRight" runat="server" title="TopRight"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
						</div>
					</td>
				</tr>
				<tr>
					<td>
						<div id="Links">
							<WebPartPages:WebPartZone id="g_9434BCAED3D240A3BAB1230244655EA3" runat="server" title="Zone 6"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
						</div>
					</td>
				</tr>
				<tr>
					<td>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td style="width:100%;" colspan="3">
			<div id="Spacing" style="margin-bottom:10px;">
				<WebPartPages:WebPartZone id="g_2F71239C045A446CB53E12A4756B7F09" runat="server" title="Zone 10"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
			</div>
		</td>
	</tr>
</table>
<script type="text/javascript" src="/Style Library/RBPv2/scripts/RBPSearch.js"></script>

</asp:Content>
<asp:Content id="Content1" runat="server" contentplaceholderid="PlaceHolderBodyAreaClass">

	<link rel="stylesheet" type="text/css" href="../../Style%20Library/RBPHomePageLayout.css" />
</asp:Content>

