use_frameworks!

def shared_pods
    pod 'CoreGPX', git: 'https://github.com/VincentNeo/CoreGPX.git'
    pod 'CryptoSwift', git: 'https://github.com/krzyzanowskim/CryptoSwift'
end

target 'OpenGpxTracker' do
    platform :ios, '8.0'
    shared_pods
    pod 'Cache', git: 'https://github.com/hyperoslo/Cache'
end

target 'OpenGpxTracker-Watch Extension' do
    platform :watchos, '2.0'
    shared_pods
end
