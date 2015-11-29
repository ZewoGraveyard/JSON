Pod::Spec.new do |s|
  s.name = 'JSON'
  s.version = '0.2'
  s.license = 'MIT'
  s.summary = 'JSON (RFC 7159) for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/JSON'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/JSON.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Dependencies/Aeson/*.c', 'JSON/**/*.swift'

  s.xcconfig =  {
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/JSON/Dependencies'
  }

  s.preserve_paths = 'Dependencies/*'

  s.requires_arc = true
end