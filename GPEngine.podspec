#
# Be sure to run `pod lib lint GPEngine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GPEngine'
  s.version          = '1.4.0'
  s.summary          = 'A Space/Entity/Component/System framework for creating games.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Space/Entity/Component/System game framework.

See https://gamedevelopment.tutsplus.com/tutorials/spaces-useful-game-object-containers--gamedev-14091 for more information about SECP.
                       DESC

  s.homepage         = 'https://github.com/LuizZak/GPEngine'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LuizZak' => 'luizinho_mack@yahoo.com.br' }
  s.source           = { :git => 'https://github.com/LuizZak/GPEngine.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/LuizZak'
  s.default_subspec  = 'Core'

  s.ios.deployment_target = '8.0'
  
  s.subspec 'Core' do |co|
    co.dependency 'GPEngine/Base'
  end
  
  s.subspec 'Base' do |base|
    base.source_files = 'Source/Base/**/*'
  end
  
  s.subspec 'Serialization' do |ser|
    ser.source_files = 'Source/Serialization/**/*'
    ser.dependency 'SwiftyJSON'
  end
end
