#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_device_state.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_device_state'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for device state detection including VPN monitoring.'
  s.description      = <<-DESC
A comprehensive Flutter plugin for device state detection including VPN, network, thermal, and battery monitoring.
                       DESC
  s.homepage         = 'https://github.com/yourusername/flutter_device_state'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
