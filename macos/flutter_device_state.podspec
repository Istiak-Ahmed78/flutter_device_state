Pod::Spec.new do |s|
  s.name             = 'flutter_device_state'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for detecting device state (VPN, security features).'
  s.description      = <<-DESC
A Flutter plugin for detecting device state including VPN connections, developer mode, screen lock, and emulator detection.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.13'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  
  # Add frameworks
  s.frameworks = 'NetworkExtension', 'LocalAuthentication'
end
