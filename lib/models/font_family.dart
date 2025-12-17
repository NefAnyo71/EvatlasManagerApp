class FontFamily {
  final String id;
  final String name;
  final String fontFamily;
  final String displayName;

  FontFamily({
    required this.id,
    required this.name,
    required this.fontFamily,
    required this.displayName,
  });

  factory FontFamily.fromJson(Map<String, dynamic> json) {
    return FontFamily(
      id: json['id'],
      name: json['name'],
      fontFamily: json['fontFamily'],
      displayName: json['displayName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fontFamily': fontFamily,
      'displayName': displayName,
    };
  }

  static List<FontFamily> getAvailableFonts() {
    return [
      FontFamily(
        id: 'playfair_display',
        name: 'Playfair Display',
        fontFamily: 'Playfair Display',
        displayName: 'Playfair Display - Elegant',
      ),
      FontFamily(
        id: 'inter',
        name: 'Inter',
        fontFamily: 'Inter',
        displayName: 'Inter - Modern',
      ),
      FontFamily(
        id: 'bebas_neue',
        name: 'Bebas Neue',
        fontFamily: 'Bebas Neue',
        displayName: 'Bebas Neue - Bold',
      ),
      FontFamily(
        id: 'pt_serif',
        name: 'PT Serif',
        fontFamily: 'PT Serif',
        displayName: 'PT Serif - Classic',
      ),
      FontFamily(
        id: 'barlow_condensed',
        name: 'Barlow Condensed',
        fontFamily: 'Barlow Condensed',
        displayName: 'Barlow Condensed - Compact',
      ),
      FontFamily(
        id: 'fjalla_one',
        name: 'Fjalla One',
        fontFamily: 'Fjalla One',
        displayName: 'Fjalla One - Strong',
      ),
      FontFamily(
        id: 'roboto',
        name: 'Roboto',
        fontFamily: 'Roboto',
        displayName: 'Roboto - Modern',
      ),
      FontFamily(
        id: 'opensans',
        name: 'Open Sans',
        fontFamily: 'Open Sans',
        displayName: 'Open Sans - Clean',
      ),
      FontFamily(
        id: 'lato',
        name: 'Lato',
        fontFamily: 'Lato',
        displayName: 'Lato - Professional',
      ),
      FontFamily(
        id: 'arimo',
        name: 'Arimo',
        fontFamily: 'Arimo',
        displayName: 'Arimo - Classic',
      ),
      FontFamily(
        id: 'oswald',
        name: 'Oswald',
        fontFamily: 'Oswald',
        displayName: 'Oswald - Bold',
      ),
      FontFamily(
        id: 'roboto_mono',
        name: 'Roboto Mono',
        fontFamily: 'Roboto Mono',
        displayName: 'Roboto Mono - Technical',
      ),
      FontFamily(
        id: 'mano',
        name: 'Manrope',
        fontFamily: 'Manrope',
        displayName: 'Manrope - Stylish',
      ),
    ];
  }

  static FontFamily getDefault() {
    return getAvailableFonts().firstWhere(
      (font) => font.id == 'inter',
      orElse: () => getAvailableFonts().first,
    );
  }
}
