Pod::Spec.new do |spec|
  spec.name         = 'ReactiveAlamofire'
  spec.version      = '2.0.0'
  spec.summary      = 'Alamofire 3 integration for ReactiveCocoa 4'
  spec.homepage     = 'https://github.com/envoy/ReactiveAlamofire'
  spec.license      = 'MIT'
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.author             = { 'Fang-Pen Lin' => 'fang@envoy.com' }
  spec.social_media_url   = 'http://twitter.com/fangpenlin'
  spec.platform     = :ios, '8.0'
  spec.source       = {
    git: 'https://github.com/envoy/ReactiveAlamofire.git',
    tag: 'v2.0.0'
  }
  spec.source_files = 'ReactiveAlamofire/*.swift'
  spec.dependency 'ReactiveSwift', '~> 1.0'
  spec.dependency 'Alamofire', '~> 4.0'
end
