platform :ios, '13.0'

target 'mymedicos-mentor' do
    use_frameworks!

  pod 'leveldb-library'         # Internal
  pod 'lottie-ios'         # Lottie Animations
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'Charts'
  pod 'libxlsxwriter'

  # Pods for mymedicos

  pod 'Firebase/Analytics'        # Firebase Core + Analytics
  pod 'Firebase/Auth'             # Firebase Authentication
  pod 'Firebase/Firestore'        # Firebase Firestore
  pod 'Firebase/Database'         # Firebase Realtime Database
  pod 'Firebase/Storage'          # Firebase Storage
  pod 'Firebase/DynamicLinks'     # Firebase Dynamic Links
  pod 'Firebase/Messaging'        # Firebase Messaging
  pod 'MarqueeLabel'
  pod 'Kingfisher'
  pod 'SkeletonView'
  pod 'Firebase/Core'
  pod 'SDWebImage'
  
  pod 'razorpay-pod'

  end

  # Optional post-install hooks to configure settings
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          # Set the deployment target for all targets
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end
