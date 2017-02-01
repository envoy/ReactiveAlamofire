Pod::Spec.new do |spec|
  spec.name         = 'ReactiveAlamofire'
  spec.version      = '1.0.0'
  spec.summary      = 'Alamofire 3 integration for ReactiveCocoa 4'
  spec.homepage     = 'https://github.com/envoy/ReactiveAlamofire'
  spec.license      = 'MIT'
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.author             = { 'Victor' => 'victor@envoy.com' }
  spec.social_media_url   = 'http://twitter.com/victorlin'
  spec.platform     = :ios, '8.0'
  spec.source       = {
    git: 'https://github.com/envoy/ReactiveAlamofire.git',
    tag: 'v1.0.0'
  }
  spec.source_files = 'ReactiveAlamofire/*.swift'
  spec.dependency 'ReactiveCocoa', '~> 5.0'
  spec.dependency 'Alamofire', '~> 4.0'
end
