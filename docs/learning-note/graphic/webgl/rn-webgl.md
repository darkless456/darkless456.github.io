---
sidebar_position: 1
---
    
# How to Integrate R3F into a CLI React Native App

1. Install the `expo` package: 
```bash
npm install expo expo-file-system expo-asset
```


2. Configure Android (`android/settings.gradle`): 
```gradle
apply from: new File(\["node", "--print", "require.resolve('expo/package.json')"].execute(null, rootDir).text.trim(), "../scripts/autolinking.gradle")
useExpoModules()
```


3. Configure iOS (`ios/Podfile`)
```ruby
target 'YourAppName' do
  use\_expo\_modules!
  config = use\_native\_modules!
  # ... rest of your config
end
```


4. install R3F
```bash
npm install three @react-three/fiber expo-gl
```

5. Rebuild

- iOS: `cd ios && pod install` then rebuild your app.

- Android: Rebuild your app (`npx react-native run-android`).

Tips:

- Metro: Start your server with the reset cache flag:
```bash
npx react-native start --reset-cache
```

- Android: Clean cache and rebuild your app.
```bash
cd android && ./gradlew clean && cd ..
npx react-native run-android
```

<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at February 28, 2026 23:31</small></div>
      