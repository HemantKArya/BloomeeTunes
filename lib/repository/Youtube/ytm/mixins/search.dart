import '../helpers.dart';
import '../yt_service_provider.dart';
import 'utils.dart';

mixin SearchMixin on YTMusicServices {
  Future<List<Map<String, dynamic>>> getSearchSuggestions(String query,
      {bool detailedRuns = false}) async {
    Map<String, dynamic> body = {'input': query};
    String endpoint = 'music/get_search_suggestions';
    List<Map<String, dynamic>> suggestions = [];
    var response = await sendRequest(endpoint, body);
    var contents = response['contents'];
    for (Map content in contents) {
      List? searchSuggestionsSectionRendererContents =
          nav(content, ['searchSuggestionsSectionRenderer', 'contents']);
      if (searchSuggestionsSectionRendererContents != null) {
        for (Map item in searchSuggestionsSectionRendererContents) {
          Map? searchSuggestionRenderer =
              nav(item, ['searchSuggestionRenderer']);
          Map? musicResponsiveListItemRenderer =
              nav(item, ['musicResponsiveListItemRenderer']);
          if (searchSuggestionRenderer != null) {
            suggestions.add(<String, dynamic>{
              'type': 'TEXT',
              'query': nav(searchSuggestionRenderer,
                  ['navigationEndpoint', 'searchEndpoint', 'query'])
            });
          } else if (musicResponsiveListItemRenderer != null) {
            suggestions.add(handleMusicResponsiveListItemRenderer(
                musicResponsiveListItemRenderer));
          }
        }
      }
    }
    return suggestions;
  }

  Future<Map<String, dynamic>> search(String query,
      {String? filter,
      String? scope,
      int limit = 30,
      bool ignoreSpelling = false,
      String additionalParams = '',
      Map<String, dynamic>? endpoint}) async {
    final data = Map.of(context);

    final filters = [
      'albums',
      'artists',
      'playlists',
      'community_playlists',
      'featured_playlists',
      'songs',
      'videos'
    ];

    if (filter != null && !filters.contains(filter)) {
      throw Exception(
          'Invalid filter provided. Please use one of the following filters or leave out the parameter: ${filters.join(', ')}');
    }

    final scopes = ['library', 'uploads'];

    if (scope != null && !scopes.contains(scope)) {
      throw Exception(
          'Invalid scope provided. Please use one of the following scopes or leave out the parameter: ${scopes.join(', ')}');
    }

    if (scope == scopes[1] && filter != null) {
      throw Exception(
          'No filter can be set when searching uploads. Please unset the filter parameter when scope is set to uploads.');
    }

    final params =
        getSearchParams(filter, scope, ignoreSpelling: ignoreSpelling);

    if (params != null) {
      data['params'] = params;
    }
    if (endpoint != null) {
      data.addAll(endpoint);
    } else {
      data['query'] = query;
    }

    final response =
        (await sendRequest("search", data, additionalParams: additionalParams));
    Map<String, dynamic> result = {};
    List contents = nav(response, [
          'contents',
          'tabbedSearchResultsRenderer',
          'tabs',
          0,
          'tabRenderer',
          'content',
          'sectionListRenderer',
          'contents'
        ]) ??
        nav(response,
            ['continuationContents', 'musicShelfContinuation', 'contents']);
    String? cont = nav(contents, [
          0,
          'musicShelfRenderer',
          'continuations',
          0,
          'nextContinuationData',
          'continuation'
        ]) ??
        nav(response, [
          'continuationContents',
          'musicShelfContinuation',
          'continuations',
          0,
          'nextContinuationData',
          'continuation'
        ]);
    String? continuationparams;
    if (cont != null) {
      continuationparams = getContinuationString(cont);
      result['continuation'] = continuationparams;
    } else {
      result['continuation'] = null;
    }
    List<Map<String, dynamic>> resultContents = [];

    Map? continuationContents = response['continuationContents'];
    for (Map content in contents) {
      Map? musicCardShelfRenderer = content['musicCardShelfRenderer'];
      Map? musicShelfRenderer = content['musicShelfRenderer'];
      if (musicCardShelfRenderer != null) {
        resultContents
            .add(_handleMusicCardShelfRenderer(musicCardShelfRenderer));
      } else if (musicShelfRenderer != null) {
        resultContents.add(handleMusicShelfRenderer(musicShelfRenderer));
      }
    }
    if (continuationContents != null) {
      resultContents.add(handleContinuationContents(
          continuationContents['musicShelfContinuation']));
    }

    result['sections'] = resultContents;
    return result;
  }

  Map<String, dynamic> _handleMusicCardShelfRenderer(Map item) {
    Map<String, dynamic> section = {};
    section.addAll(_handleHeader(
        nav(item, ['header', 'musicCardShelfHeaderBasicRenderer'])));
    section['contents'] = [];
    section['contents'].add(_handleTopResult(item));
    List? contents = nav(item, ['contents']);
    if (contents != null) {
      section['contents'].addAll(handleContents(contents));
    }
    return section;
  }

  Map<String, dynamic> _handleHeader(Map header) {
    Map<String, dynamic> headerMap = {
      'title': nav(header, ['title', 'runs', 0, 'text']),
      'trailing': {
        'text': nav(header,
            ['moreContentButton', 'buttonRenderer', 'text', 'runs', 0, 'text']),
        'playable': nav(header, [
              'moreContentButton',
              'buttonRenderer',
              'navigationEndpoint',
              'watchPlaylistEndpoint'
            ]) !=
            null,
        'endpoint': nav(header, [
          'moreContentButton',
          'buttonRenderer',
          'navigationEndpoint',
          'watchPlaylistEndpoint'
        ]),
      }
    };
    return headerMap;
  }

  _handleTopResult(Map item) {
    Map? browseEndpoint =
        nav(item, ['title', 'runs', 0, 'navigationEndpoint', 'browseEndpoint']);
    Map? watchEndpoint =
        nav(item, ['title', 'runs', 0, 'navigationEndpoint', 'watchEndpoint']);
    List? subtitle = nav(item, ['subtitle', 'runs']);
    Map<String, dynamic> top = {
      'thumbnails': nav(item,
          ['thumbnail', 'musicThumbnailRenderer', 'thumbnail', 'thumbnails']),
      'title': nav(item, ['title', 'runs', 0, 'text']),
      'videoId': watchEndpoint?['videoId'],
      'type': itemCategory[nav(browseEndpoint, [
            'browseEndpointContextSupportedConfigs',
            'browseEndpointContextMusicConfig',
            'pageType'
          ]) ??
          nav(watchEndpoint, [
            'watchEndpointMusicSupportedConfigs',
            'watchEndpointMusicConfig',
            'musicVideoType'
          ])],
      'endpoint': browseEndpoint,
      'subtitle': subtitle?.map((e) => e['text']).join('')
    };
    if (subtitle != null) {
      top.addAll(checkRuns(subtitle));
    }
    top.removeWhere((key, val) => val == null || val.isEmpty);
    return top;
  }
}

String? getSearchParams(String? filter, String? scope,
    {bool ignoreSpelling = true}) {
  String filteredParam1 = 'EgWKAQ';
  String? params;
  String param1 = '';
  String param2 = '';
  String param3 = '';

  if (filter == null && scope == null && !ignoreSpelling) {
    return params;
  }

  if (scope == 'uploads') {
    params = 'agIYAw%3D%3D';
  }

  if (scope == 'library') {
    if (filter != null) {
      param1 = filteredParam1;
      param2 = _getParam2(filter);
      param3 = 'AWoKEAUQCRADEAoYBA%3D%3D';
    } else {
      params = 'agIYBA%3D%3D';
    }
  }

  if (scope == null && filter != null) {
    if (filter == 'playlists') {
      params = 'Eg-KAQwIABAAGAAgACgB';
      if (!ignoreSpelling) {
        params += 'MABqChAEEAMQCRAFEAo%3D';
      } else {
        params += 'MABCAggBagoQBBADEAkQBRAK';
      }
    } else if (filter.contains('playlists')) {
      param1 = 'EgeKAQQoA';
      if (filter == 'featured_playlists') {
        param2 = 'Dg';
      } else {
        param2 = 'EA';
      }

      if (!ignoreSpelling) {
        param3 = 'BagwQDhAKEAMQBBAJEAU%3D';
      } else {
        param3 = 'BQgIIAWoMEA4QChADEAQQCRAF';
      }
    } else {
      param1 = filteredParam1;
      param2 = _getParam2(filter);
      if (!ignoreSpelling) {
        param3 = 'AWoMEA4QChADEAQQCRAF';
      } else {
        param3 = 'AUICCAFqDBAOEAoQAxAEEAkQBQ%3D%3D';
      }
    }
  }

  if (scope == null && filter == null && ignoreSpelling) {
    params = 'EhGKAQ4IARABGAEgASgAOAFAAUICCAE%3D';
  }

  return params ?? (param1 + param2 + param3);
}

String _getParam2(String filter) {
  Map<String, String> filterParams = {
    'songs': 'II',
    'videos': 'IQ',
    'albums': 'IY',
    'artists': 'Ig',
    'playlists': 'Io',
    'profiles': 'JY',
    'podcasts': 'JQ',
    'episodes': 'JI'
  };
  return filterParams[filter]!;
}
