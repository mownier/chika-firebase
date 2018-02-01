source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/mownier/chika-podspecs.git'
source 'https://github.com/mownier/podspecs.git'
platform :ios, '11.0'
use_frameworks!

target 'ChikaFirebase' do
  pod 'FirebaseCommunity/Database'
  pod 'FirebaseCommunity/Auth'
  pod 'ChikaCore'
  pod 'TNExtensions/EmailValidator'
  
  target 'ChikaFirebaseTests' do
      inherit! :search_paths
  end
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
        if config.name == 'Release'
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        end
    end
end
