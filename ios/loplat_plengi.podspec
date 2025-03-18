
Pod::Spec.new do |s|
  s.name             = 'loplat_plengi'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for getting commonly used locations on the filesystem.'
  s.description      = <<-DESC
   A Flutter plugin for getting commonly used locations on the filesystem.
                       DESC
  s.homepage         = 'https://developers.loplat.com/'
  s.author           = { 'loplat' => 'rym@loplat.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Plengi' , '1.5.8-rc1'
  s.vendored_frameworks = 'Framework/MiniPlengi.framework'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  # i386 -> arm64
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'

  end
