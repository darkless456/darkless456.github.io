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
1. Old way
apply from: new File(["node", "--print", "require.resolve('expo/package.json')"].execute(null, rootDir).text.trim(), "../scripts/autolinking.gradle")
useExpoModules()

2. New way
pluginManagement {
    includeBuild("../node_modules/@react-native/gradle-plugin")
    
    // 1. ADD THIS EXPO BLOCK to locate the new plugin
    def expoPluginsPath = new File(
        providers.exec {
            workingDir(rootDir)
            commandLine("node", "--print", "require.resolve('expo-modules-autolinking/package.json', { paths: [require.resolve('expo/package.json')] })")
        }.standardOutput.asText.get().trim(),
        "../android/expo-gradle-plugin"
    ).absolutePath
    includeBuild(expoPluginsPath)
}

plugins {
    id("com.facebook.react.settings")
    // 2. ADD THIS LINE to apply the plugin
    id("expo-autolinking-settings") 
}

extensions.configure(com.facebook.react.ReactSettingsExtension){ ex ->
    // 3. MODIFY THIS LINE to pass the Expo command
    ex.autolinkLibrariesFromCommand(expoAutolinking.rnConfigCommand) 
}

rootProject.name = 'YourAppName' // <-- Keep your actual project name here
include ':app'
includeBuild('../node_modules/@react-native/gradle-plugin')

// 4. ADD THESE 3 LINES AT the very bottom
expoAutolinking.useExpoModules()
expoAutolinking.useExpoVersionCatalog()
includeBuild(expoAutolinking.reactNativeGradlePlugin)
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

<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at March 1, 2026 00:14</small></div>
      