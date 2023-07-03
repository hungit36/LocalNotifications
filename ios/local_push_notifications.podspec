#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint local_push_notifications.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'local_push_notifications'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/hungit36/LocalNotifications'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'hungnguyen.it36@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'NO',
    'ENABLE_BITCODE' => 'NO',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'NO',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  s.swift_version = '5.0'
end
