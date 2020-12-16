#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hypertrack.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name                = 'hypertrack_plugin'
  s.version             = '0.1.5'
  s.summary             = 'A new flutter plugin project.'
  s.description         = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage            = 'http://example.com'
  s.license             = { :file => '../LICENSE' }
  s.author              = { 'Your Company' => 'email@example.com' }
  s.source              = { :path => '.' }
  s.cocoapods_version   = '>= 1.10.0'
  s.source_files        = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency          'Flutter'
  s.dependency          'HyperTrack/Objective-C', '4.6.0'
  s.platform            = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
