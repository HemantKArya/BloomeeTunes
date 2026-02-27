

enum SourceEngine {
  eng_JIS("JISaavn"),
  eng_YTM("YTMusic"),
  eng_YTV("YTVideo");

  final String value;
  const SourceEngine(this.value);
}

/// Map defining which source engines are available in which countries.
/// Empty list means available in all countries.
Map<SourceEngine, List<String>> sourceEngineCountries = {
  SourceEngine.eng_JIS: [
    "IN",
    "NP",
    "BT",
    "LK",
  ],
  SourceEngine.eng_YTM: [],
  SourceEngine.eng_YTV: [],
};
