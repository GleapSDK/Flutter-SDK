#
# CocoaPods build of the plugin, for apps without Swift Package Manager (Flutter < 3.41 or
# SwiftPM turned off). Sources are shared with the Swift package in gleap_sdk/ (Package.swift);
# keep the Gleap version below in sync with it.
#
Pod::Spec.new do |s|
  s.name             = 'gleap_sdk'
  s.version          = '19.0.0'
  s.summary          = 'Gleap SDK for Flutter'
  s.description      = 'Gleap SDK for Flutter with customer support, live chat, bug reporting and feedback.'
  s.homepage         = 'https://www.gleap.ai'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gleap GmbH' => 'hello@gleap.io' }
  s.source           = { :path => '.' }
  s.source_files = 'gleap_sdk/Sources/gleap_sdk/**/*.{h,m}'
  s.public_header_files = 'gleap_sdk/Sources/gleap_sdk/include/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.dependency 'Gleap', '19.0.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
