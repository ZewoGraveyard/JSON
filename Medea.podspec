Pod::Spec.new do |s|
  s.name = 'Medea'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'JSON for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Medea'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Medea.git', :tag => 'v0.1' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Medea/**/*.swift'

  s.requires_arc = true
end