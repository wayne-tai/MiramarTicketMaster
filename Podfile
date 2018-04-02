source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

abstract_target 'target' do
  # Networking
  pod 'Alamofire', '~> 4.5.0'
  
  # Logging
  pod 'SwiftyBeaver', '~> 1.4.0'

  # Rx
  pod 'RxSwift', '~> 3.6.1'
  pod 'RxCocoa', '~> 3.6.1'
  pod 'RxAlamofire', '~> 3.0.3'
  
  # Swift class extensions
  pod 'SwifterSwift', '~> 3.2.0'
  
  # AutoLayout
  pod 'SnapKit', '~> 3.2.0'

  target 'MiramarTicketMaster'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        puts "Updating #{target.name} build settings"
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'YES'
            config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
	    config.build_settings['SWIFT_VERSION'] = '3.2' 
        end
    end
end
