/// Sheet-style overlay vs full-screen pushed route chrome.
enum OverlayFormPresentation {
  /// In a modal sheet or bounded navigator — drag handle, manual top padding.
  inSheet,

  /// Full-screen route — [CustomAppBar] and [SafeArea] for system insets.
  fullScreen,
}
