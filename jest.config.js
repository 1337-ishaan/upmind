module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEach: [],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg|react-native-reanimated|@react-native-async-storage/.*)/)',
  ],
  testPathIgnorePatterns: ['/node_modules/', '/.expo/', '/dist/'],
};
