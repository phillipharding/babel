/* This file is currently associated to an HTML file of the same name and is drawing content from it.  Until the files are disassociated, you will not be able to move, delete, rename, or make any other changes to this file. */

function DisplayTemplate_888167637cbd4b858ef78b9f8c0b9c80(ctx) {
  var ms_outHtml=[];
  var cachePreviousTemplateData = ctx['DisplayTemplateData'];
  ctx['DisplayTemplateData'] = new Object();
  DisplayTemplate_888167637cbd4b858ef78b9f8c0b9c80.DisplayTemplateData = ctx['DisplayTemplateData'];

  ctx['DisplayTemplateData']['TemplateUrl']='~sitecollection\u002f_catalogs\u002fmasterpage\u002fDisplay Templates\u002fSearch\u002fBuzz365\u002fItem_NewsByCategory.js';
  ctx['DisplayTemplateData']['TemplateType']='Item';
  ctx['DisplayTemplateData']['TargetControlType']=['SearchResults'];
  this.DisplayTemplateData = ctx['DisplayTemplateData'];

  ctx['DisplayTemplateData']['ManagedPropertyMapping']={'Title':['Title'], 'AuthorOWSUSER':['AuthorOWSUSER'], 'EditorOWSUSER':['EditorOWSUSER'], 'Path':['Path'], 'LastModifiedTime':['LastModifiedTime'], 'Created':['Created'], 'HitHighlightedSummary':['HitHighlightedSummary'], 'HitHighlightedProperties':['HitHighlightedProperties'], 'ParentLink':['ParentLink'], 'AttachmentDescription':['AttachmentDescription'], 'AttachmentType':['AttachmentType'], 'AttachmentURI':['AttachmentURI'], 'RootPostID':['RootPostID'], 'LikesCount':['LikesCount'], 'NewsPostPublishedDate':['NewsPostPublishedDate'], 'NewsPostCategory':['NewsPostCategory'], 'NewsRollupImageOWSIMGE':['NewsRollupImageOWSIMGE'], 'NewsPageImageOWSIMGE':['NewsPageImageOWSIMGE'], 'BodyOWSMTXT':['BodyOWSMTXT']};
  var cachePreviousItemValuesFunction = ctx['ItemValues'];
  ctx['ItemValues'] = function(slotOrPropName) {
    return Srch.ValueInfo.getCachedCtxItemValue(ctx, slotOrPropName)
};

ms_outHtml.push('',''
,'	'
);

  ctx['ItemValues'] = cachePreviousItemValuesFunction;
  ctx['DisplayTemplateData'] = cachePreviousTemplateData;
  return ms_outHtml.join('');
}
function RegisterTemplate_888167637cbd4b858ef78b9f8c0b9c80() {

if ("undefined" != typeof (Srch) &&"undefined" != typeof (Srch.U) &&typeof(Srch.U.registerRenderTemplateByName) == "function") {
  Srch.U.registerRenderTemplateByName("Item_NewsByCategory", DisplayTemplate_888167637cbd4b858ef78b9f8c0b9c80);
}

if ("undefined" != typeof (Srch) &&"undefined" != typeof (Srch.U) &&typeof(Srch.U.registerRenderTemplateByName) == "function") {
  Srch.U.registerRenderTemplateByName("~sitecollection\u002f_catalogs\u002fmasterpage\u002fDisplay Templates\u002fSearch\u002fBuzz365\u002fItem_NewsByCategory.js", DisplayTemplate_888167637cbd4b858ef78b9f8c0b9c80);
}

}
RegisterTemplate_888167637cbd4b858ef78b9f8c0b9c80();
if (typeof(RegisterModuleInit) == "function" && typeof(Srch.U.replaceUrlTokens) == "function") {
  RegisterModuleInit(Srch.U.replaceUrlTokens("~sitecollection\u002f_catalogs\u002fmasterpage\u002fDisplay Templates\u002fSearch\u002fBuzz365\u002fItem_NewsByCategory.js"), RegisterTemplate_888167637cbd4b858ef78b9f8c0b9c80);
}