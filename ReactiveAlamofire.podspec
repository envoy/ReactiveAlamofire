Pod::Spec.new do |spec|
  spec.name         = 'ReactiveAlamofire'
  spec.version      = '3.0.0'
  spec.summary      = 'Alamofire 4.5 integration for ReactiveSwift 2'
  spec.homepage     = 'https://github.com/envoy/ReactiveAlamofire'
  spec.license      = 'MIT'
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.author             = { 'Fang-Pen Lin' => 'fang@envoy.com' }
  spec.social_media_url   = 'https://twitter.com/fangpenlin'
  spec.platform     = :ios, '9.0'
  spec.source       = {
    git: 'https://github.com/envoy/ReactiveAlamofire.git',
    tag: 'v3.0.0'
  }
  spec.source_files = 'ReactiveAlamofire/*.swift'
  spec.dependency 'ReactiveSwift', '~> 2.0'
  spec.dependency 'Alamofire', '~> 4.5'
end
