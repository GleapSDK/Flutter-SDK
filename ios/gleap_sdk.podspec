#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint gleap_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'gleap_sdk'
  s.version          = '7.0.15'
  s.summary          = 'Gleap SDK for Flutter'
  s.description      = 'The Gleap SDK for Flutter is the easiest way to integrate Gleap into your apps!'
  s.homepage         = 'https://gleap.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gleap GmbH' => 'hello@gleap.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.dependency 'Gleap', '7.0.16'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
