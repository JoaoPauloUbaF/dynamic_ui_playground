import 'dart:convert';

/// Holds the current dynamic UI JSON and exposes updates.
class DynamicUiController {
  DynamicUiController({Map<String, dynamic>? initialJson})
    : _json = initialJson ?? _defaultJson;

  Map<String, dynamic> _json;

  static Map<String, dynamic> get _defaultJson => {
    'type': 'container',
    'props': {
      'color': 'red',
      'padding': {'all': 12},
    },
    'children': [
      {
        'type': 'column',
        'props': {
          'mainAxisAlignment': 'center',
          'crossAxisAlignment': 'center',
        },
        'children': [
          {
            'type': 'text',
            'props': {
              'value': 'Dynamic UI Playground',
              'size': 22,
              'align': 'center',
            },
          },
          {
            'type': 'sizedBox',
            'props': {'height': 16},
          },
          {
            'type': 'row',
            'props': {
              'mainAxisAlignment': 'spaceEvenly',
              'crossAxisAlignment': 'center',
            },
            'children': [
              {
                'type': 'icon',
                'props': {'icon': 'mic', 'size': 28, 'color': '#FF6200EE'},
              },
              {
                'type': 'text',
                'props': {'value': 'Tap mic to speak', 'size': 16},
              },
            ],
          },
          {
            'type': 'container',
            'props': {
              'color': 'transparent',
              'padding': {'all': 12},
            },
            'children': [
              {
                'type': 'column',
                'children': [
                  {
                    'type': 'text',
                    'props': {'value': 'Login', 'size': 18},
                  },
                  {
                    'type': 'sizedBox',
                    'props': {'height': 8},
                  },
                  {
                    'type': 'textField',
                    'props': {'hint': 'Email'},
                  },
                  {
                    'type': 'sizedBox',
                    'props': {'height': 8},
                  },
                  {
                    'type': 'textField',
                    'props': {'hint': 'Password', 'obscureText': true},
                  },
                  {
                    'type': 'sizedBox',
                    'props': {'height': 12},
                  },
                  {
                    'type': 'elevatedButton',
                    'props': {'label': 'Sign in'},
                  },
                ],
              },
            ],
          },
          {
            'type': 'sizedBox',
            'props': {'height': 12},
          },
          {
            'type': 'image',
            'props': {
              'url': 'https://picsum.photos/200/300',
              'fit': 'contain',
              'height': 60,
            },
          },
        ],
      },
    ],
  };

  Map<String, dynamic> get json => _json;

  set json(Map<String, dynamic> value) {
    _json = value;
  }

  String get jsonPretty => const JsonEncoder.withIndent('  ').convert(_json);
}
