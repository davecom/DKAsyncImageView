Pod::Spec.new do |s|
  s.name             = 'DKAsyncImageView'
  s.version          = '1.0.4'
  s.license          = 'MIT'
  s.summary          = 'A Swift subclass of NSImageView for loading remote images asynchronously.'
  s.homepage         = 'https://github.com/davecom/DKAsyncImageView'
  s.social_media_url = 'https://twitter.com/davekopec'
  s.authors          = { 'David Kopec' => 'david@oaksnow.com' }
  s.source           = { :git => 'https://github.com/davecom/DKAsyncImageView.git', :tag => s.version }

  s.swift_versions = ['4.0', '5.0']
  
  s.osx.deployment_target = '10.13'

  s.source_files = 'Sources/DKAsyncImageView/DKAsyncImageView.swift'
  s.requires_arc = true
end
