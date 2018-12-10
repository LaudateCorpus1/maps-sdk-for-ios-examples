source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.1'
use_frameworks!

def tomtom_pods
  pod 'TomTomOnlineSDKSearch', '2.3.98'
  pod 'TomTomOnlineSDKRouting', '2.3.98'
  pod 'TomTomOnlineSDKMaps', '2.3.98'
  pod 'TomTomOnlineSDKMapsUIExtensions', '2.3.98'
  pod 'TomTomOnlineSDKMapsStaticImage', '2.3.98'
  pod 'TomTomOnlineSDKTraffic', '2.3.98'
end

target 'MapsSDKExamplesSwift' do
  tomtom_pods
end

target 'MapsSDKExamplesObjc' do
  tomtom_pods
end

target 'MapsSDKExamplesCommon' do
  tomtom_pods
end

target 'MapsSDKExamplesVC' do
  tomtom_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      target.build_settings(configuration.name)['VALID_ARCHS'] = 'arm64'
      target.build_settings(configuration.name)['ONLY_ACTIVE_ARCH'] = 'NO'
      target.build_settings(configuration.name)['GCC_C_LANGUAGE_STANDARD'] = 'compiler-default'
    end
  end
end
