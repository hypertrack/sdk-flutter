#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hypertrack.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name                = 'hypertrack_plugin'
  s.version             = '1.1.2'
  s.summary             = 'HyperTrack SDK Flutter plugin is a wrapper around native HyperTrack SDK that allows to integrate it into Flutter apps'
  s.description         = <<-DESC
HyperTrack SDK Flutter plugin is a wrapper around native HyperTrack SDK that allows to integrate it into Flutter apps
                       DESC
  s.homepage            = 'http://example.com'
  s.license             = { :file => '../LICENSE' }
  s.author              = { 'Your Company' => 'email@example.com' }
  s.source              = { :path => '.' }
  s.cocoapods_version   = '>= 1.10.0'
  s.source_files        = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency          'Flutter'
  s.dependency          'HyperTrack', '4.16.0'
  s.platform            = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
