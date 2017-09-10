# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'SuLi' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for SuLi
  pod 'Kanna'
  pod 'SwiftHTTP'
  pod 'RealmSwift'
  pod 'XLPagerTabStrip'
  pod 'TOSMBClient'

end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-SuLi/Pods-SuLi-acknowledgements.plist', 'SuLi/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    FileUtils.cp_r('Pods/Target Support Files/Pods-SuLi/Pods-SuLi-acknowledgements.markdown', 'Acknowledgements.md', :remove_destination => true)
end
