# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'SuLi' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  inhibit_all_warnings!
  
  # Pods for SuLi
  pod 'Kanna', '2.2.1'
  pod 'SwiftHTTP', '2.0.2'
  pod 'RealmSwift'
  pod 'XLPagerTabStrip', '8.0.0'
  pod 'TOSMBClient'
  pod 'DZNEmptyDataSet'
  
  pod 'Google-Mobile-Ads-SDK', '7.27.0'

end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-SuLi/Pods-SuLi-acknowledgements.plist', 'SuLi/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    FileUtils.cp_r('Pods/Target Support Files/Pods-SuLi/Pods-SuLi-acknowledgements.markdown', 'Acknowledgements.md', :remove_destination => true)
end
