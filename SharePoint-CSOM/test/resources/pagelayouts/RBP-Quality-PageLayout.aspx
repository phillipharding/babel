﻿<%@ Page language="C#"   Inherits="Microsoft.SharePoint.Publishing.PublishingLayoutPage,Microsoft.SharePoint.Publishing,Version=14.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register Tagprefix="SharePointWebControls" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingWebControls" Namespace="Microsoft.SharePoint.Publishing.WebControls" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="PublishingNavigation" Namespace="Microsoft.SharePoint.Publishing.Navigation" Assembly="Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="RBNav" Namespace="RB.Buzz.WebControls.Navigation" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>
<%@ Register TagPrefix="RBNews" Namespace="RB.Buzz.WebControls.News" Assembly="RB.Buzz.WebControls, Version=1.0.0.0, Culture=neutral, PublicKeyToken=fc480efd1438eb4c" %>

<asp:Content ContentPlaceholderID="PlaceHolderPageTitle" runat="server">
	<SharePointWebControls:FieldValue id="PageTitle" FieldName="Title" runat="server"/>
</asp:Content>
<asp:Content ContentPlaceholderID="PlaceHolderMain" runat="server">

<asp:Content ContentPlaceholderID="PlaceHolderAdditionalPageHead" runat="server">
	<SharePointWebControls:CssRegistration runat="server" Name="/Style Library/RBPv2/css/Quality.css"
		After="/Style Library/RBPv2/css/rbp-v2-typography.css"/>
</asp:Content>


<WebPartPages:SPProxyWebPartManager runat="server" id="spproxywebpartmanager"></WebPartPages:SPProxyWebPartManager>
<table class="rb_wrapper" >
<tr>
<td style="width:75%;vertical-align:top;">
<table style="width:100%; ">
<tr><td id="tdWelcome" colspan="2" >

<div id="Spacing" style="margin-bottom:0px;">
<WebPartPages:WebPartZone id="g_DAE70724F60341AEA8F643705B691289" runat="server" title="Zone 1"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>


</td></tr>
<tr><td colspan="2">
<div id="Spacing" style="margin-bottom:0px;">
<WebPartPages:WebPartZone id="g_86CF6365DB184C2A94CFB75D0E66761E" runat="server" title="Zone 9"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>
</td></tr>
<tr><td  colspan="2">


<div id="Spacing" style="margin-bottom:0px;">
<WebPartPages:WebPartZone id="g_3BE428479C594AF38172E7557E3D55AE" runat="server" title="Zone 2"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>



</td></tr>
<tr>
<td style="width:50%;vertical-align:top;">
<div id="Spacing" class="SmallHeadIMG" style="margin-bottom:20px;">
<WebPartPages:WebPartZone id="g_E8F2065587B146989FAB96A65FA9DEB8" runat="server" title="Zone 3"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>
</td>
<td style="width:50%; vertical-align:top;">
<div id="Spacing" class="SmallHeadIMG" style="margin-bottom:20px;">
<WebPartPages:WebPartZone id="g_B7373E03BF5D4B54A0958F4035B81258" runat="server" title="Zone 7"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>
</td>
</tr>
<tr><td colspan="2" style="width:75%;">

<div id="Spacing" style="margin-bottom:20px;">
<WebPartPages:WebPartZone id="g_202EDEEB4698469C9741DC346EBC83CD" runat="server" title="Zone 8"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>

</td></tr>




</table>
</td>
<td style="width:25%; vertical-align:top;">
<table style="width:100%">
<tr><td>

<div id="Spacing" style="margin-bottom:20px;">
<WebPartPages:WebPartZone id="g_BE27785520834C91BCC46BE6F08DC2A9" runat="server" title="Zone 4"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>

</td></tr>
<tr><td>




<div id="Spacing" style="margin-bottom:20px;">
<WebPartPages:WebPartZone id="g_B95F82BC1A174E8BBFDBE5D2BD23D1CA" runat="server" title="Zone 5"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>




</td></tr>
<tr><td>

<div id="Spacing" style="margin-bottom:20px;">
<WebPartPages:WebPartZone id="g_9434BCAED3D240A3BAB1230244655EA3" runat="server" title="Zone 6"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</div>

</td></tr>
</table>
</td>
</tr>
<tr>
<td style="width:100%;" colspan="3">

<div id="Spacing" style="margin-bottom:20px;">
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

