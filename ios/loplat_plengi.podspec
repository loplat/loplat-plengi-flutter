
Pod::Spec.new do |s|
  s.name             = 'loplat_plengi'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for getting commonly used locations on the filesystem.'
  s.description      = <<-DESC
   A Flutter plugin for getting commonly used locations on the filesystem.
                       DESC
  s.homepage         = 'https://developers.loplat.com/'
  s.author           = { 'loplat' => 'pgj0320@loplat.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Plengi' , '1.5.14'
  s.platform = :ios, '12.0'

  s.swift_version = '5.0'

  end
