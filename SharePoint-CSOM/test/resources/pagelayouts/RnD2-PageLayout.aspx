<%@ Page language="C#"   Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<asp:Content ContentPlaceholderID="PlaceHolderPageTitle" runat="server">
	<SharePointWebControls:FieldValue id="PageTitle" FieldName="Title" runat="server"/>
</asp:Content>
<asp:Content ContentPlaceholderID="PlaceHolderMain" runat="server">
<div id="Container" style="width: 1200px; height: auto; margin: 0 auto; margin-top:20px;">

<!-------------------------------------------------6 BUTTON MENU ROW---------------------------------------------------------------------------->
<div id="Menu" style="width: 100%; padding-bottom: 20px;">
	<WebPartPages:WebPartZone runat="server" Title="ButtonMenu" ID="ButtonMenu"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>


<div id="LeftColumn" style="float:left; width: 65%;">

<!-------------------------------------------------TOP ROW---------------------------------------------------------------------------->
<div id="TopRow" style="float: left; width: 100%; padding-bottom: 15px;">

	<div id="Overview" style="width: 100%; float: left;">
		<div class="head">						
			<div class="Overview long">
				<span>Overview of Research &amp; Development</span>
			</div>
		</div>
			<WebPartPages:WebPartZone runat="server" Title="TopLeft" ID="TopLeft"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
	</div>
		
</div>

<!-------------------------------------------------2ND ROW--------------------------------------------------------------------------->
<div id="SecondRow" style="float: left; width: 100%; padding-bottom: 15px;">

	<div id="RnDNews" style="width: 100%; float: left;">
		<div class="head">
			<div class="news long">
				<span class="">R&amp;D News</span>
			</div>
		</div>
			<WebPartPages:WebPartZone runat="server" Title="SecondRow" ID="SecondRow"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
	</div>
</div>
<!-------------------------------------------------3RD ROW---------------------------------------------------------------------------->
<div id="ThirdRow" style="float: left; width: 100%; padding-bottom: 15px;">

	<div id="Announcements" style="width: 100%; float: left;">
		<div class="head">						
			<div class="announcements long">
				<span class="">Announcements</span>
			</div>
		</div>
			<WebPartPages:WebPartZone runat="server" Title="ThirdRow" ID="ThirdRow"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
	</div>
	
</div>

<!-------------------------------------------------4TH ROW---------------------------------------------------------------------------->
<div id="FourthRow" style="float: left; width: 100%; padding-bottom: 15px;">

	<div id="FourthRowLeft" style="width: 49.6%; float: left; padding-right: 20px;">
		<div class="head">						
			<div class="calendar short">
				<span class="">Calendar</span>
			</div>
		</div>
			<WebPartPages:WebPartZone runat="server" Title="FourthRowRight" ID="FourthRowLeft"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
	</div>
	<div id="Stories" style="width: 47.7%; float: left;">
			<WebPartPages:WebPartZone runat="server" Title="FourthRowRight" ID="FourthRowRight"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
	</div>
</div>
</div>
<!------------------------------------------------RIGHT COLUMN--------------------------------------------------------------------------->
<div id="RightContainer" style="width: 33.3%; float: left; padding-left: 20px;">
<div id="RightColumn" style="width: 100%;">
		<div class="head">						
			<div class="Mission short">
				<span class="">R&amp;D Mission</span>
			</div>
		</div>
		<WebPartPages:WebPartZone runat="server" Title="Menu" ID="Menu"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
		<div id="Spacing" style="margin-bottom:10px;">
			<WebPartPages:WebPartZone id="g_9434BCAED3D240A3BAB1230244655EA3" runat="server" title="Zone 6"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
			</div>

</div>
</div>

</div>
<script type="text/javascript" src="/Style Library/RBPv2/scripts/RBPSearch.js"></script>
</asp:Content>
