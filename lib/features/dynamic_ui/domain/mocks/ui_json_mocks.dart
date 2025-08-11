/// UI JSON mocks for suggestions
const List<String> kDefaultSuggestions = [
  'Create a login screen with email and password',
  'Add a profile header with avatar and name',
  'Build a 2x2 grid of product cards',
  'Show a list of news articles with images',
  'Compose a settings page with toggles',
];

Map<String, dynamic>? getMockForPrompt(String prompt) {
  switch (prompt) {
    case 'Create a login screen with email and password':
      return _loginScreen();
    case 'Add a profile header with avatar and name':
      return _profileHeader();
    case 'Build a 2x2 grid of product cards':
      return _productGrid();
    case 'Show a list of news articles with images':
      return _newsList();
    case 'Compose a settings page with toggles':
      return _settingsPage();
    default:
      return null;
  }
}

Map<String, dynamic> _loginScreen() => {
  'type': 'container',
  'props': {
    'decoration': {'color': '#FFFFFFFF'},
    'padding': {'all': 16},
  },
  'children': [
    {
      'type': 'column',
      'props': {
        'mainAxisAlignment': 'center',
        'crossAxisAlignment': 'center',
        'spacing': 16,
      },
      'children': [
        {
          'type': 'text',
          'props': {'value': 'Welcome back', 'size': 26, 'fontFamily': 'Inter'},
        },
        {
          'type': 'textField',
          'props': {'hint': 'Email', 'prefixIcon': 'email', 'borderRadius': 12},
        },
        {
          'type': 'textField',
          'props': {
            'hint': 'Password',
            'prefixIcon': 'lock',
            'obscureText': true,
            'borderRadius': 12,
          },
        },
        {
          'type': 'elevatedButton',
          'props': {
            'label': 'Sign In',
            'style': {
              'backgroundColor': '#FF6200EE',
              'padding': {'all': 12},
              'borderRadius': 12,
            },
          },
        },
      ],
    },
  ],
};

Map<String, dynamic> _profileHeader() => {
  'type': 'container',
  'props': {
    'decoration': {'color': '#FFF6F6F6'},
    'padding': {'all': 24},
  },
  'children': [
    {
      'type': 'column',
      'props': {
        'spacing': 12,
        'mainAxisAlignment': 'center',
        'crossAxisAlignment': 'center',
      },
      'children': [
        {
          'type': 'container',
          'props': {'alignment': 'center'},
          'children': [
            {
              'type': 'image',
              'props': {
                'url': 'https://i.pravatar.cc/150?img=5',
                'fit': 'cover',
                'height': 120,
                'width': 120,
              },
            },
          ],
        },
        {
          'type': 'text',
          'props': {'value': 'Jane Doe', 'size': 22, 'fontFamily': 'Inter'},
        },
        {
          'type': 'row',
          'props': {'spacing': 12, 'mainAxisAlignment': 'center'},
          'children': [
            {
              'type': 'icon',
              'props': {'icon': 'add', 'size': 20},
            },
            {
              'type': 'text',
              'props': {'value': 'Follow', 'size': 16},
            },
          ],
        },
      ],
    },
  ],
};

Map<String, dynamic> _productGrid() => {
  'type': 'column',
  'props': {'spacing': 12},
  'children': [
    {
      'type': 'row',
      'props': {'spacing': 12},
      'children': [
        _productCard(
          'Coffee Beans',
          'https://picsum.photos/seed/coffee/200/120',
          '#FFB388FF',
        ),
        _productCard(
          'Matcha Tea',
          'https://picsum.photos/seed/tea/200/120',
          '#FF81C784',
        ),
      ],
    },
    {
      'type': 'row',
      'props': {'spacing': 12},
      'children': [
        _productCard(
          'Dark Chocolate',
          'https://picsum.photos/seed/choco/200/120',
          '#FF90CAF9',
        ),
        _productCard(
          'Granola',
          'https://picsum.photos/seed/granola/200/120',
          '#FFFFF59D',
        ),
      ],
    },
  ],
};

Map<String, dynamic> _productCard(
  String title,
  String imageUrl,
  String color,
) => {
  'type': 'container',
  'props': {
    'decoration': {
      'color': color,
      'borderRadius': {'all': 12},
    },
    'padding': {'all': 12},
  },
  'children': [
    {
      'type': 'column',
      'props': {'spacing': 8},
      'children': [
        {
          'type': 'image',
          'props': {'url': imageUrl, 'fit': 'cover', 'height': 100},
        },
        {
          'type': 'text',
          'props': {'value': title, 'size': 16},
        },
      ],
    },
  ],
};

Map<String, dynamic> _newsList() => {
  'type': 'column',
  'props': {'spacing': 12},
  'children': List.generate(5, (i) => _newsItem(i)),
};

Map<String, dynamic> _newsItem(int i) => {
  'type': 'row',
  'props': {'spacing': 12},
  'children': [
    {
      'type': 'image',
      'props': {
        'url': 'https://picsum.photos/seed/news$i/120/80',
        'fit': 'cover',
        'height': 80,
        'width': 120,
      },
    },
    {
      'type': 'column',
      'props': {'spacing': 6, 'mainAxisSize': 'min'},
      'children': [
        {
          'type': 'text',
          'props': {'value': 'Headline $i', 'size': 16},
        },
        {
          'type': 'sizedBox',
          'props': {'height': 40, 'width': 250},
          'children': [
            {
              'type': 'text',
              'props': {
                'value':
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                'size': 12,
                'overflow': 'ellipsis',
                'maxLines': 2,
              },
            },
          ],
        },
      ],
    },
  ],
};

Map<String, dynamic> _settingsPage() => {
  'type': 'column',
  'props': {'spacing': 12},
  'children': [
    _settingsTile('Notifications', true),
    _settingsTile('Dark Mode', false),
    _settingsTile('Location Services', true),
    _settingsTile('Backup over Wi-Fi', true),
  ],
};

Map<String, dynamic> _settingsTile(String label, bool value) => {
  'type': 'row',
  'props': {
    'mainAxisAlignment': 'spaceBetween',
    'crossAxisAlignment': 'center',
  },
  'children': [
    {
      'type': 'text',
      'props': {'value': label, 'size': 16},
    },
    // we don't have a switch DS yet, simulate with icon
    {
      'type': 'icon',
      'props': {'icon': value ? 'add' : 'close', 'size': 20},
    },
  ],
};
