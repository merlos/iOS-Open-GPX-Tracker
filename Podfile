use_frameworks!

def shared_pods
    pod 'CoreGPX', git: 'https://github.com/VincentNeo/CoreGPX.git'
end

target 'OpenGpxTracker' do
    platform :ios, '8.0'
    shared_pods
    pod 'MapCache', '~> 0.5.3'
end

target 'OpenGpxTracker-Watch Extension' do
    platform :watchos, '2.0'
    shared_pods
end
