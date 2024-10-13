# Uncomment the next line to define a global platform for your project

DebugConfigurations = ['Debug']

def DebugSupport(configurations)
  
  pod "GCDWebServer/WebDAV", "~> 3.0", :configurations => configurations
  pod "GCDWebServer/WebUploader", "~> 3.0", :configurations => configurations
  
end

target 'GithubNote' do
  
  platform :osx, '14.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Highlightr', '2.1.0'
  pod 'Moya', '~> 15.0'
  pod 'AlertToast', '1.3.9'
  pod 'CocoaLumberjack/Swift', '3.8.5'
  pod 'FMDB', '2.7.12'
  
  DebugSupport DebugConfigurations
  
  target 'GithubNoteTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GithubNoteUITests' do
    # Pods for testing
  end

end

target 'GithubNoteMobile' do
  
  platform :ios, '17.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Highlightr', '2.1.0'
  pod 'Moya', '~> 15.0'
  pod 'AlertToast', '1.3.9'
  pod 'CocoaLumberjack/Swift', '3.8.5'
  pod 'FMDB', '2.7.12'
  
  DebugSupport DebugConfigurations

end



post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["MACOSX_DEPLOYMENT_TARGET"] = "14.0"
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
    end
  end
end
