class SharedPreferenceHelper {
  static String getNameKey(channelId) {
    return '$channelId-name';
  }

  static String getProfilePictureKey(channelId) {
    return '$channelId-picture';
  }

  static String getSubscribersKey(channelId) {
    return '$channelId-subscribers';
  }

  static String getSubscriberDiffernceKey() {
    return 'notify-subscriber-difference';
  }

  static String getLongPressScreenshotKey() {
    return 'long-press-screenshot';
  }

  static String getThemeId() {
    return 'themeId';
  }

  static String getAppExplanationKey() {
    return 'isAppExplained';
  }
}
