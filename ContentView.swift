name: Build IPA

on: [push]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and Package
        run: |
          mkdir -p Payload/DynamicNotch.app
          xcrun -sdk iphoneos swiftc -parse-as-library -target arm64-apple-ios15.0 -framework MediaPlayer ContentView.swift -o Payload/DynamicNotch.app/DynamicNotch
          
          cat << 'EOF' > Payload/DynamicNotch.app/Info.plist
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
              <key>CFBundleExecutable</key>
              <string>DynamicNotch</string>
              <key>CFBundleIdentifier</key>
              <string>com.maliyildirimer.dynamicnotch</string>
              <key>CFBundleName</key>
              <string>DynamicNotch</string>
              <key>CFBundlePackageType</key>
              <string>APPL</string>
              <key>CFBundleShortVersionString</key>
              <string>1.0</string>
              <key>CFBundleVersion</key>
              <string>1</string>
              <key>LSRequiresIPhoneOS</key>
              <true/>
              <key>MinimumOSVersion</key>
              <string>15.0</string>
              <key>NSAppleMusicUsageDescription</key>
              <string>Müzik bilgilerini çentikte gösterebilmek için izin gerekiyor.</string>
          </dict>
          </plist>
          EOF

          zip -r DynamicNotch.ipa Payload

      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: DynamicNotch-IPA
          path: DynamicNotch.ipa
