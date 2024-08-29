const content = ['contents', 0];
const runText = ['runs', 0, 'text'];
const tabContent = ['tabs', 0, 'tabRenderer', 'content'];
const tab1Content = ['tabs', 1, 'tabRenderer', 'content'];
const singleColumn = ['contents', 'singleColumnBrowseResultsRenderer'];
const singleColumnTab = [...singleColumn, ...tabContent];
const sectionList = ['sectionListRenderer', 'contents'];
const sectionListItem = ['sectionListRenderer', ...content];
const itemSection = ['itemSectionRenderer', ...content];
const musicShelf = ['musicShelfRenderer'];
const musicShelfContent = [...musicShelf, ...content];
const musicShelfContents = [...musicShelf, 'contents'];
const grid = ['gridRenderer'];
const gridItems = [...grid, 'items'];
const menu = ['menu', 'menuRenderer'];
const menuItems = [...menu, 'items'];
const menuLikeStatus = [
  ...menu,
  'topLevelButtons',
  0,
  'likeButtonRenderer',
  'likeStatus'
];
const menuService = ['menuServiceItemRenderer', 'serviceEndpoint'];
const toggleMenu = 'toggleMenuServiceItemRenderer';
const playButton = [
  'overlay',
  'musicItemThumbnailOverlayRenderer',
  'content',
  'musicPlayButtonRenderer'
];
const navigationBrowse = ['navigationEndpoint', 'browseEndpoint'];
const navigationBrowseId = [...navigationBrowse, 'browseId'];
const pageType = [
  'browseEndpointContextSupportedConfigs',
  'browseEndpointContextMusicConfig',
  'pageType'
];
const navigationVideoId = ['navigationEndpoint', 'watchEndpoint', 'videoId'];
const navigationPlaylistId = [
  'navigationEndpoint',
  'watchEndpoint',
  'playlistId'
];
const navigationWatchPlaylistId = [
  'navigationEndpoint',
  'watchPlaylistEndpoint',
  'playlistId'
];
const navigationVideoType = [
  'watchEndpoint',
  'watchEndpointMusicSupportedConfigs',
  'watchEndpointMusicConfig',
  'musicVideoType'
];
const headerDetail = ['header', 'musicDetailHeaderRenderer'];
const immersiveHeaderDetail = ['header', 'musicImmersiveHeaderRenderer'];
const descriptionShelf = ['musicDescriptionShelfRenderer'];
const description = ['description', ...runText];
const carousel = ['musicCarouselShelfRenderer'];
const immersiveCarousel = ['musicImmersiveCarouselShelfRenderer'];
const carouselContents = [...carousel, 'contents'];
const carouselTitle = [
  'header',
  'musicCarouselShelfBasicHeaderRenderer',
  'title',
  'runs',
  0
];
const twoColumnRenderer = ['contents', 'twoColumnBrowseResultsRenderer'];
const musicResponsiveHeader = [
  ...twoColumnRenderer,
  ...tabContent,
  ...sectionListItem,
  'musicResponsiveHeaderRenderer',
];
const frameworkMutations = [
  'frameworkUpdates',
  'entityBatchUpdate',
  'mutations'
];
const title = ['title', 'runs', 0];
const titleText = ['title', ...runText];
const textRuns = ['text', 'runs'];
const textRun = [...textRuns, 0];
const textRunText = [...textRun, 'text'];
const subtitle = ['subtitle', runText];
const subtitleRuns = ['subtitle', 'runs'];
const secondaryContents = 'secondaryContents';
const secondSubtitleRuns = ['secondSubtitle', 'runs'];
const subtitle2 = ['subtitle', 'runs', 2, 'text'];
const subtitle3 = ['subtitle', 'runs', 4, 'text'];
const thumbnail = ['thumbnail', 'thumbnails'];
const thumbnails = ['thumbnail', 'musicThumbnailRenderer', ...thumbnail];
const thumbnailRenderer = [
  'thumbnailRenderer',
  'musicThumbnailRenderer',
  ...thumbnail
];
const thumbnailCropped = [
  'thumbnail',
  'croppedSquareThumbnailRenderer',
  ...thumbnail
];
const feedbackToken = ['feedbackEndpoint', 'feedbackToken'];
const badgePath = [
  0,
  'musicInlineBadgeRenderer',
  'accessibilityData',
  'accessibilityData',
  'label'
];
const badgeLabel = ['badges', ...badgePath];
const subtitleBadgeLabel = ['subtitleBadges', ...badgePath];
const categoryTitle = [
  'musicNavigationButtonRenderer',
  'buttonText',
  ...runText
];
const categoryParams = [
  'musicNavigationButtonRenderer',
  'clickCommand',
  'browseEndpoint',
  'params'
];
const mTRIR = 'musicTwoRowItemRenderer';
const mRLIR = 'musicResponsiveListItemRenderer';
const mRLIFCR = 'musicResponsiveListItemFlexColumnRenderer';
const mrlirPlaylistId = [mRLIR, 'playlistItemData', 'videoId'];
const tasteProfileItems = ['contents', 'tastebuilderRenderer', 'contents'];
const tasteProfileArtist = ['title', 'runs'];
const sectionListContinuation = [
  'continuationContents',
  'sectionListContinuation'
];
const menuPlaylistId = [
  ...menuItems,
  0,
  'menuNavigationItemRenderer',
  ...navigationWatchPlaylistId
];

dynamic nav(dynamic root, List items) {
  try {
    dynamic res = root;
    for (final item in items) {
      res = res[item];
    }
    return res;
  } catch (e) {
    return null;
  }
}

String joinRunTexts(List runs) {
  return runs.map((e) => e['text']).toList().join();
}

List runUrls(List runs) {
  return runs.map((e) => e['url']).toList();
}
