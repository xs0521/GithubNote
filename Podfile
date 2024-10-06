# Uncomment the next line to define a global platform for your project
platform :osx, '14.0'

target 'GithubNote' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Highlightr', '2.1.0'
  pod 'Moya', '~> 15.0'
  pod 'Cache', :git => 'https://github.com/hyperoslo/Cache.git', :tag => '7.2.0'
  pod 'AlertToast', '1.3.9'
  pod 'CocoaLumberjack/Swift', '3.8.5'
  pod 'FMDB', '2.7.12'
  
  pod "GCDWebServer/WebDAV", "~> 3.0"
  pod "GCDWebServer/WebUploader", "~> 3.0"

  # Pods for GithubNote

  target 'GithubNoteTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GithubNoteUITests' do
    # Pods for testing
  end

end
