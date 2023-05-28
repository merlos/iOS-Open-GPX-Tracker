use_frameworks!

def shared_pods
    pod 'CoreGPX', git: 'https://github.com/vincentneo/CoreGPX.git'
end

target 'OpenGpxTracker' do
    platform :ios, '11.0'
    shared_pods
    pod 'MapCache', '~> 0.10.0'
    #pod 'MapCache', git: 'https://github.com/vincentneo/MapCache.git', :branch => 'ios16-add-overlay-patch'
    
end

target 'OpenGpxTracker-Watch Extension' do
    platform :watchos, '4.0'
    shared_pods
end
