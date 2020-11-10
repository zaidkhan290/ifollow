//
//  CameraViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 06/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import ColorSlider
import GooglePlaces
import AVKit
import Photos
import OpenTok
import SwiftGifOrigin

protocol CameraViewControllerDelegate: class {
    func getStoryImage(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel])
    func getStoryVideo(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel] )
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var emojiesMainView: UIView!
    @IBOutlet weak var editableTextFieldView: UIView!
    @IBOutlet weak var btnEmoji: UIButton!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var btnRotate: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var btnClock: UIButton!
    @IBOutlet weak var btnText: UIButton!
    @IBOutlet weak var btnTag: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var lblLive: UILabel!
    @IBOutlet weak var lblNormal: UILabel!
    @IBOutlet weak var lblVideo: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var editableTextField: UITextView!
    @IBOutlet weak var fontSlider: UISlider!
    @IBOutlet weak var lblFont: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var clockIcon: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var recordingIcon: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var txtFieldCaption: UITextField!
    @IBOutlet weak var lblUserTags: UILabel!
    @IBOutlet weak var lblVideoTimer: UILabel!
    @IBOutlet weak var captureAnimationImg: UIImageView!
    
    @IBOutlet var m_overlayView: UIView!
    
    @IBOutlet var timeViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var timeViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var locationViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var locationViewCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet var editableTextViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var editableTextViewCenterXConstraint: NSLayoutConstraint!
    
    var isBackTapped = false
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput: AVCaptureMovieFileOutput!
    var flashMode = AVCaptureDevice.FlashMode.off
    var torchMode = AVCaptureDevice.TorchMode.off
    var audioDeviceInput: AVCaptureDeviceInput!
    var isFrontCamera = false
    var isPictureCaptured = false
    var emojis = [UIImage]()
    var imagePicker = UIImagePickerController()
    var isLive = false
    var isVideo = false
    var colorSlider: ColorSlider!
    var fontSize: Float = 30.0
    var selectedFont = ""
    var timeViewFrame: CGRect!
    var locationViewFrame: CGRect!
    var timeViewStyle = 0 // 0 for no boarder // 1 for Yellow, 2 for unfill, 3 for white
    var locationViewStyle = 0 // 0 for no boarder // 1 for Yellow, 2 for unfill, 3 for white
    var timeViewTapGesture = UITapGestureRecognizer()
    var locationViewTapGesture = UITapGestureRecognizer()
    var fontsNames = ["Rightland", "LemonMilk", "Cream", "Gobold", "Janda", "Poetsen", "Simplisicky", "Evogria", "Yellosun"]
    let filters = ["","CIPhotoEffectMono", "CIPhotoEffectChrome", "CIPhotoEffectTransfer", "CIPhotoEffectInstant", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectFade"]
    var selectedFilter = 0
    var selectedImage = UIImage()
    var delegate: CameraViewControllerDelegate!
    var videoURL: URL!
    var finalEditedVideoURL: URL!
    var tagUsersArrray = [PostLikesUserModel]()
    var tagUsersString = ""
    
    var timer = Timer()
    var seconds = 0
    
    var storyImageToSend = UIImage()
    
    var isForPost = false
    var shouldSaveToGallery = false
    
    // Replace with your OpenTok API key
    var kApiKey = "46828384"
    // Replace with your generated session ID
    var kSessionId = "2_MX40NjgyODM4NH5-MTU5NDIwMzgzNTc1MX5JNllPczFHVHljRzZYQlBLS0ZUcHpEb0h-fg"
    // Replace with your generated token
    var kToken = "T1==cGFydG5lcl9pZD00NjgyODM4NCZzaWc9MjA5MmUzMjFkNzA1MmY3YjhhOGZlOTk3OGVmYjYwNzcyYzA4OWE5YTpzZXNzaW9uX2lkPTJfTVg0ME5qZ3lPRE00Tkg1LU1UVTVOREl3TXpnek5UYzFNWDVKTmxsUGN6RkhWSGxqUnpaWVFsQkxTMFpVY0hwRWIwaC1mZyZjcmVhdGVfdGltZT0xNTk0MjAzODcyJm5vbmNlPTAuNDU4MTMwMzk2OTMxODgxMDcmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTU5NDIwNzQ3MCZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ=="
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    
    var player: AVPlayer!
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 15.0
    var lastZoomFactor: CGFloat = 1.0
    var latestDirection: Int = 0
    var gestRecognizer : UIPinchGestureRecognizer?;
    var longPressGesture : UILongPressGestureRecognizer?
    var panGestureRecognizer : InstantPanGestureRecognizer?
    private var initialZoom: CGFloat = 1.0
    private var isStartedRecording : Bool = false
    
    
    //MARK:- Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //------ For loading Emojis ------//
        let ranges = [0x1F601...0x1F64F /*, 0x2702...0x27B0*/]
        emojis = ranges
            .flatMap { $0 }
            .compactMap { Unicode.Scalar($0) }
            .map(Character.init)
            .compactMap { String($0).image() }
        
        //------ For loading Emojis ------
        
     
        recordingIcon.layer.cornerRadius = recordingIcon.frame.height / 2
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.videoMaximumDuration = 60//isForPost ? 60 : 15
        imagePicker.videoQuality = .type640x480
        
        editableTextField.delegate = self
        txtFieldCaption.layer.cornerRadius = 10
        txtFieldCaption.setLeftPaddingPoints(10)
        txtFieldCaption.setRightPaddingPoints(10)
        Utility.setTextFieldPlaceholder(textField: txtFieldCaption, placeholder: "Add a caption...", color: .white)
        
        btnEmoji.isEnabled = false
        btnLocation.isHidden = true
        btnText.isHidden = true
        btnClock.isHidden = true
        btnTag.isHidden = true
        txtFieldCaption.isHidden = true
        
        lblLive.isUserInteractionEnabled = true
        lblLive.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lblLiveTapped)))
        lblNormal.isUserInteractionEnabled = true
        lblNormal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lblNormalTapped)))
        lblVideo.isUserInteractionEnabled = true
        lblVideo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lblVideoTapped)))
        
        lblFont.layer.borderWidth = 1
        lblFont.layer.borderColor = UIColor.white.cgColor
        lblFont.layer.cornerRadius = lblFont.frame.height / 2
        lblFont.layer.masksToBounds = true
        lblFont.text = fontsNames.first!
        lblFont.isUserInteractionEnabled = true
        lblFont.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lblFontsTapped)))
        
        timeView.layer.cornerRadius = 5
        timeViewFrame = timeView.frame
        timeViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(timeViewTapped))
        timeViewTapGesture.delegate = self
        clockIcon.isUserInteractionEnabled = true
        lblTime.isUserInteractionEnabled = true
        clockIcon.addGestureRecognizer(timeViewTapGesture)
        lblTime.addGestureRecognizer(timeViewTapGesture)
        changeTimeViewStyle()
        
        locationView.layer.cornerRadius = 5
        locationViewFrame = locationView.frame
        locationViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(locationViewTapped))
        locationViewTapGesture.delegate = self
        locationIcon.isUserInteractionEnabled = true
        lblLocation.isUserInteractionEnabled = true
        locationIcon.addGestureRecognizer(locationViewTapGesture)
        lblLocation.addGestureRecognizer(locationViewTapGesture)
        changeLocationViewStyle()
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeftGesture.direction = .left
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRightGesture.direction = .right
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                //self.captureSession.stopRunning()
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                //self.initCustomCamera()
            }
            
        }
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(rotateCamera))
        doubleTapGesture.numberOfTapsRequired = 2
        self.previewView.addGestureRecognizer(doubleTapGesture)
        
        panGestureRecognizer = InstantPanGestureRecognizer(target: self, action: #selector(panGesture))
        self.btnCapture.addGestureRecognizer(self.panGestureRecognizer!)
        self.panGestureRecognizer?.delegate = self
        
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGesture))
        self.btnCapture.addGestureRecognizer(self.longPressGesture!)
        self.longPressGesture?.delegate = self
        
        
        gestRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)));
        //self.cameraView.addGestureRecognizer(gestRecognizer!);
        self.previewView.addGestureRecognizer(gestRecognizer!)
        self.captureAnimationImg.loadGif(name: "capture_animation")
        
      //  connectToAnOpenTokSession()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        initCustomCamera()
        
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .right)
        colorSlider.frame = CGRect(x: 20, y: (UIScreen.main.bounds.height / 2) - 150, width: 15, height: 300)
        view.addSubview(colorSlider)
        colorSlider.isHidden = true
        colorSlider.addTarget(self, action: #selector(colorSliderValueChanged(_:)), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }
    }
    
    func initCustomCamera(){
        //----- For AVCaptureSession Start-----//
            
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            captureSession.automaticallyConfiguresApplicationAudioSession = false
        
            //captureSession.usesApplicationAudioSession = true
            
            
            guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
                else {
                    print("Unable to access back camera!")
                    return
            }
            
            do {
                
                let input = try AVCaptureDeviceInput(device: backCamera)
                stillImageOutput = AVCapturePhotoOutput()
                movieOutput = AVCaptureMovieFileOutput()
                
                if let microphone = AVCaptureDevice.default(for: AVMediaType.audio){
                    do {
                        let micInput = try AVCaptureDeviceInput(device: microphone)
                        if captureSession.canAddInput(micInput) {
                            captureSession.addInput(micInput)
                        }
                    } catch {
                        print("Error setting device audio input: \(error)")
                    }
                }
                let audioSession = AVAudioSession.sharedInstance();
//                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP]);
                
                
                if (detectBluetoothAudioConnected(audioSession: audioSession)){
                    
                    try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP]);
                    try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                }
                else{
                    try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP]);
                    try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                }
                
                try audioSession.setActive(true);
                
                if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(stillImageOutput)
                    captureSession.addOutput(movieOutput)
                    setupLivePreview()
                }


            }
            catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
            
            //----- For AVCaptureSession End-----//
    }
    
    func deleteFile(filePath:NSURL) {
        guard FileManager.default.fileExists(atPath: filePath.path!) else {
            return
        }
        
        do { try FileManager.default.removeItem(atPath: filePath.path!)
        } catch { fatalError("Unable to delete file: \(error)") }
    }
    
    func convertVideoAndSaveTophotoLibrary(videoURL: URL) {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp\(Date().timeIntervalSince1970).mp4").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory2.appendingPathComponent("video\(Date().timeIntervalSince1970).mp4")
        deleteFile(filePath: filePath as NSURL)

        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do { try FileManager.default.removeItem(atPath: myDocumentPath)
            } catch let error { print(error) }
        }
        
        Utility.showOrHideLoader(shouldShow: true)
        // File to composit
        let asset = AVURLAsset(url: videoURL as URL)
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

        // Rotate to potrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform
    
        //fix orientation
        var videoAssetOrientation_  = UIImage.Orientation.up
        
        var isVideoAssetPortrait_  = false
        
        if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
            videoAssetOrientation_ = UIImage.Orientation.right
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
            videoAssetOrientation_ =  UIImage.Orientation.left
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
            videoAssetOrientation_ =  UIImage.Orientation.up
        }
        if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
            videoAssetOrientation_ = UIImage.Orientation.down;
        }
        
        let transform = CGAffineTransform(a: videoTransform.a, b: videoTransform.b, c: videoTransform.c, d: videoTransform.d, tx: videoTransform.tx, ty: 0)
        
        //transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
        transformer.setTransform(transform, at: CMTime.zero)
        transformer.setOpacity(0.0, at: asset.duration)
        
        //adjust the render size if neccessary
        var naturalSize: CGSize
        
        if(isVideoAssetPortrait_){
            naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
        } else {
            if (isFrontCamera)
            {
                naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
            }
            else
            {
                naturalSize = clipVideoTrack.naturalSize;
            }
        }
        
        var renderWidth: CGFloat!
        var renderHeight: CGFloat!
        
        renderWidth = naturalSize.width
        renderHeight = naturalSize.height
        
        let parentlayer = CALayer()
        let videoLayer = CALayer()
        let watermarkLayer = CALayer()
        
        
        //let videoComposition = AVMutableVideoComposition()
        let watermarkImage = CIImage(image:self.m_overlayView.asImage())
        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        let videoComposition = AVMutableVideoComposition(asset: asset,  applyingCIFiltersWithHandler: { request in
            //let source = request.sourceImage.clampedToExtent()
            let source = request.sourceImage
            var filteredImg = source
            if self.selectedFilter > 0
            {
                let filter = CIFilter(name: self.filters[self.selectedFilter])
                filter!.setValue(source , forKey: kCIInputImageKey)
                let context = CIContext(options:nil)
                let cgimg = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
                filteredImg = CIImage(cgImage: cgimg!)
                //request.finish(with: filteredImag, context: nil)
     
            }
            
            print("filtred image ", filteredImg.extent.width , " Height = ", filteredImg.extent.height);
            print("watermak image " ,watermarkImage?.extent.width, "Height = ", watermarkImage?.extent.height);
            
            watermarkFilter.setValue(filteredImg, forKey: "inputBackgroundImage")
            //let transform = CGAffineTransform(translationX: filteredImg.extent.width - (watermarkImage?.extent.width)! - 2, y: 0)
            
            let transform = CGAffineTransform(scaleX: filteredImg.extent.width / (watermarkImage?.extent.width)!, y: filteredImg.extent.height / (watermarkImage?.extent.height)!)
            
            watermarkFilter.setValue(watermarkImage?.transformed(by: transform), forKey: "inputImage")
            request.finish(with: watermarkFilter.outputImage!, context: nil)
            
        })
        videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderScale = 1.0
        
        watermarkLayer.contents = m_overlayView.asImage().cgImage
        
        parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        videoLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        
        parentlayer.addSublayer(videoLayer)
        parentlayer.addSublayer(watermarkLayer)
        
        // Add watermark to video
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(60, preferredTimescale: 30))
        
        
        instruction.layerInstructions = [transformer]
        //videoComposition.instructions = [instruction]
        
        let exporter = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputFileType = AVFileType.mov
        exporter?.outputURL = filePath
        exporter?.videoComposition = videoComposition
        
        exporter!.exportAsynchronously(completionHandler: {() -> Void in
            if exporter?.status == .completed {
                print("Completed")
                let outputURL: URL? = exporter?.outputURL
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                }) { saved, error in
                    Utility.showOrHideLoader(shouldShow: false)
                    if saved {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                        PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                            let newObj = avurlAsset as! AVURLAsset
                            print(newObj.url)
                            DispatchQueue.main.async(execute: {
                                self.finalEditedVideoURL = newObj.url
                                print(newObj.url.absoluteString)
                                if (self.player != nil){
                                    self.player.pause()
                                }
                                if (self.isForPost){
                                    self.dismiss(animated: true, completion: nil)
                                    if (self.videoURL == nil){
                                        self.delegate.getStoryImage(image: self.storyImageToSend, caption: "", isToSendMyStory: true, friendsArray: [], selectedTagsUserString: self.tagUsersString, selectedTagUsersArray: self.tagUsersArrray)
                                    }
                                    else{
                                        self.delegate.getStoryVideo(videoURL: self.finalEditedVideoURL, caption: "", isToSendMyStory: true, friendsArray: [], selectedTagsUserString: self.tagUsersString, selectedTagUsersArray: self.tagUsersArrray)
                                    }
                                }
                                else{
                                    let vc = Utility.getShareStoriesViewController()
                                    vc.delegate = self
                                    self.pushToVC(vc: vc)
                                }
                            })
                        })
                        print (fetchResult!)
                    }
                }
            }
        })
        
        
    }
    
    func detectBluetoothAudioConnected(audioSession: AVAudioSession) -> Bool{
        let outputs = audioSession.currentRoute.outputs
        for output in outputs{
            if output.portType == .bluetoothA2DP || output.portType == .bluetoothHFP || output.portType == .bluetoothLE || output.portType == .headphones || output.portType == .carAudio || output.portType == .usbAudio{
                return true
          }
        }
        return false
    }
    
    @objc func longGesture(sender: UILongPressGestureRecognizer){
        
        print("Long")
        if (sender.state == .began)
        {
            if (isVideo)
            {
                if (!isStartedRecording)
                {
                    OnTappRecording()
                }
            }
        }
        else if (sender.state == .ended)
        {
            if (isVideo)
            {
                if (isStartedRecording)
                {
                    OnTappRecording()
                }
            }
        }
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer){
        
        var device : AVCaptureDevice!
        
        let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaType.video, position: .unspecified)
        let devices = videoDeviceDiscoverySession.devices
        device = devices.first!
        

        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        let newScaleFactor = minMaxZoom(gestRecognizer!.scale * lastZoomFactor)
        switch gestRecognizer!.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    fileprivate func swapCamera(){

        // Get current input
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }

        // Begin new session configuration and defer commit
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }

        // Create new capture input
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        // Swap capture device inputs
        captureSession.removeInput(input)
        captureSession.addInput(deviceInput)
    }
    
    /// Create new capture device with requested position
    fileprivate func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {

        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    @objc func panGesture(_ sender: UIPanGestureRecognizer) {
        
        // note that 'view' here is the overall video preview
        let velocity = sender.velocity(in: view)
        
        if velocity.y >= 0 || velocity.y <= 0 {
            
            _ = captureSession
            var devitce : AVCaptureDevice!
            
            if (isFrontCamera)
            {
                devitce = cameraWithPosition(position: .front)
                
            }
            else
            {
                devitce = cameraWithPosition(position: .back)
            }
            
            guard let device = devitce else { return }
            
            let minimumZoomFactor: CGFloat = minimumZoom;
            let maximumZoomFactor: CGFloat = min(device.activeFormat.videoMaxZoomFactor, maximumZoom) // artificially set a max useable zoom of 15x
        
            var videoConnection:AVCaptureConnection?
            for connection in self.movieOutput.connections {
              for port in connection.inputPorts {
                  if port.mediaType == AVMediaType.video {
                  videoConnection = connection as? AVCaptureConnection
                      if videoConnection!.isVideoMirroringSupported {
                        if (isFrontCamera)
                        {
                          videoConnection!.isVideoMirrored = true
                        }
                        else
                        {
                            videoConnection!.isVideoMirrored = false
                        }
                          
                    }
                  }
                }
             }
            
            // clamp a zoom factor between minimumZoom and maximumZoom
            func clampZoomFactor(_ factor: CGFloat) -> CGFloat {
                return min(max(factor, minimumZoomFactor), maximumZoomFactor)
            }
            
            func update(scale factor: CGFloat) {
                do {
                    
                    try device.lockForConfiguration()
                    defer { device.unlockForConfiguration() }
                    device.videoZoomFactor = factor
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
            
            switch sender.state {
            case .began:
                initialZoom = device.videoZoomFactor
                //startRecording() /// call to start recording your video
                if (!isStartedRecording && isVideo)
                {
                    OnTappRecording();
                }
                break;
            case .changed:
                
                // distance in points for the full zoom range (e.g. min to max), could be view.frame.height
                let fullRangeDistancePoints: CGFloat = 300.0
                
                // extract current distance travelled, from gesture start
                let currentYTranslation: CGFloat = sender.translation(in: view).y
                
                // calculate a normalized zoom factor between [-1,1], where up is positive (ie zooming in)
                let normalizedZoomFactor = -1 * max(-1,min(1,currentYTranslation / fullRangeDistancePoints))
                
                // calculate effective zoom scale to use
                let newZoomFactor = clampZoomFactor(initialZoom + normalizedZoomFactor * (maximumZoomFactor - minimumZoomFactor))
                
                lastZoomFactor = newZoomFactor
                // update device's zoom factor'
                update(scale: newZoomFactor)
                break;
            case .ended, .cancelled:
                //stopRecording() /// call to start recording your video
                if (isStartedRecording && isVideo)
                {
                    OnTappRecording()
                }
                else if (!isVideo && !isLive)
                {
                    OnTappRecording()
                }
                break;
                
            default:
                break
            }
        }
    }
    
    func setZoomFactor(scale factor: CGFloat){
        var devitce : AVCaptureDevice!
        if (isFrontCamera)
        {
            devitce = cameraWithPosition(position: .front)
            
        }
        else
        {
            devitce = cameraWithPosition(position: .back)
        }
        guard let device = devitce else { return }
        
        func update(scale factor: CGFloat) {
            do {
                
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        lastZoomFactor = factor

        update(scale: factor)
        
    }
    func convert(cmage:CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func addVideoPlayer(videoUrl: URL, to view: UIView) {
        
        let asset = AVAsset(url: videoUrl)
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = AVVideoComposition(asset: asset,  applyingCIFiltersWithHandler: { request in
            //let source = request.sourceImage.clampedToExtent()
            let source = request.sourceImage
            if self.selectedFilter > 0
            {
                
                let filter = CIFilter(name: self.filters[self.selectedFilter])
                filter!.setValue(source , forKey: kCIInputImageKey)

                let context = CIContext(options:nil)
                let cgimg = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
                let filteredImag = CIImage(cgImage: cgimg!)
                
                request.finish(with: filteredImag, context: nil)
            }
            else
            {
                request.finish(with: source, context: nil)
            }
        })
        player = AVPlayer(playerItem: item)
        
        //player = AVPlayer(url: videoUrl)
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        
        let width = player.currentItem?.asset.tracks.filter{$0.mediaType == .video}.first?.naturalSize.width.rounded()
        let height = player.currentItem?.asset.tracks.filter{$0.mediaType == .video}.first?.naturalSize.height.rounded()
        if (Int(width!) > Int(height!)){
            layer.videoGravity = .resizeAspect
        }
        else if (Int(width!) == Int(height!)){
            layer.videoGravity = .resizeAspect
        }
        else{
            layer.videoGravity = .resizeAspectFill
        }
        
        view.layer.sublayers?
            .filter { $0 is AVPlayerLayer }
            .forEach { $0.removeFromSuperlayer() }
        view.layer.sublayers?.removeAll()
        view.layer.addSublayer(layer)
        player.play();
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self!.player.seek(to: CMTime.zero)
            self!.player.play()
        }
        
    }
    
    @objc func swipeUpToGetStickers(){
        let vc = Utility.getEmojisViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func changeView(isVideoSelected: Bool){
        //btnGallery.isHidden = isVideoSelected
        btnGallery.isHidden = false
        //btnEmoji.isHidden = isVideoSelected
        //btnText.isHidden = isVideoSelected
        btnEmoji.isEnabled = true
        btnLocation.isEnabled = true
        btnLocation.isHidden = false
        btnClock.isHidden = false
        btnText.isHidden = false
        btnTag.isHidden = false
        //btnLocation.isHidden = isVideoSelected
        btnFlash.isHidden = isVideoSelected
        btnRotate.isHidden = isVideoSelected
        timeViewCenterYConstraint.constant = 0
        timeViewCenterXConstraint.constant = 0
        locationViewCenterYConstraint.constant = 0
        locationViewCenterXConstraint.constant = 0
        editableTextViewCenterXConstraint.constant = 0
        editableTextViewCenterYConstraint.constant = 0
        // btnPlay.isHidden = !isVideoSelected
        if (!isForPost){
            txtFieldCaption.isHidden = false
        }
        
    }
    
    @objc func colorSliderValueChanged(_ slider: ColorSlider) {
        let color = slider.color
        editableTextField.textColor = color
    }

    @objc func lblLiveTapped(){
        isLive = true
        isVideo = false
        btnGallery.isEnabled = false
        lblLive.font = Theme.getLatoBoldFontOfSize(size: 18)
        lblNormal.font = Theme.getLatoRegularFontOfSize(size: 15)
        lblVideo.font = Theme.getLatoRegularFontOfSize(size: 15)
    }
    
    @objc func lblNormalTapped(){
        isLive = false
        isVideo = false
        btnGallery.isEnabled = true
        lblNormal.font = Theme.getLatoBoldFontOfSize(size: 18)
        lblLive.font = Theme.getLatoRegularFontOfSize(size: 15)
        lblVideo.font = Theme.getLatoRegularFontOfSize(size: 15)
    }
    
    @objc func lblVideoTapped(){
        isLive = false
        isVideo = true
        btnGallery.isEnabled = true
        lblVideo.font = Theme.getLatoBoldFontOfSize(size: 18)
        lblLive.font = Theme.getLatoRegularFontOfSize(size: 15)
        lblNormal.font = Theme.getLatoRegularFontOfSize(size: 15)

    }
    
    @objc func timeViewTapped(){
        if (timeViewStyle == 0){
            timeViewStyle = 1
        }
        else if (timeViewStyle == 1){
            timeViewStyle = 2
        }
        else if (timeViewStyle == 2){
            timeViewStyle = 3
        }
        else if (timeViewStyle == 3){
            timeViewStyle = 0
        }
        changeTimeViewStyle()
    }
    
    @objc func locationViewTapped(){
        if (locationViewStyle == 0){
            locationViewStyle = 1
        }
        else if (locationViewStyle == 1){
            locationViewStyle = 2
        }
        else if (locationViewStyle == 2){
            locationViewStyle = 3
        }
        else if (locationViewStyle == 3){
            locationViewStyle = 0
        }
        changeLocationViewStyle()
    }
    
    @objc func changeTimeViewStyle(){
        if (timeViewStyle == 0){
            timeView.backgroundColor = .clear
            timeView.layer.borderColor = UIColor.clear.cgColor
            lblTime.textColor = .white
            clockIcon.image = UIImage(named: "clock-unfill")
        }
        else if (timeViewStyle == 1){
            timeView.backgroundColor = Theme.profileLabelsYellowColor
            timeView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
            lblTime.textColor = .white
            clockIcon.image = UIImage(named: "clock-unfill")
        }
        else if (timeViewStyle == 2){
            timeView.backgroundColor = .clear
            timeView.layer.borderWidth = 1
            timeView.layer.borderColor = UIColor.white.cgColor
            lblTime.textColor = .white
            clockIcon.image = UIImage(named: "clock-unfill")
        }
        else if (timeViewStyle == 3){
            timeView.backgroundColor = .white
            lblTime.textColor = .black
            clockIcon.image = UIImage(named: "clock-fill")
        }
    }
    
    @objc func changeLocationViewStyle(){
        if (locationViewStyle == 0){
            locationView.backgroundColor = .clear
            locationView.layer.borderColor = UIColor.clear.cgColor
            lblLocation.textColor = .white
            locationIcon.image = UIImage(named: "location-unfill")
        }
        else if (locationViewStyle == 1){
            locationView.backgroundColor = Theme.profileLabelsYellowColor
            locationView.layer.borderColor = Theme.profileLabelsYellowColor.cgColor
            lblLocation.textColor = .white
            locationIcon.image = UIImage(named: "location-unfill")
        }
        else if (locationViewStyle == 2){
            locationView.backgroundColor = .clear
            locationView.layer.borderWidth = 1
            locationView.layer.borderColor = UIColor.white.cgColor
            lblLocation.textColor = .white
            locationIcon.image = UIImage(named: "location-unfill")
        }
        else if (locationViewStyle == 3){
            locationView.backgroundColor = .white
            lblLocation.textColor = .black
            locationIcon.image = UIImage(named: "location-fill")
        }
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.frame
            }
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        captureAnimationImg.isHidden = true
        btnCapture.alpha = 1
        shouldSaveToGallery = true
        var image = UIImage(data: imageData)
        if (isFrontCamera){
            image = image?.sd_flippedImage(withHorizontal: true, vertical: false)
        }
        cameraView.isHidden = false
        selectedImage = image!
        cameraView.contentMode = .scaleAspectFill
        cameraView.image = image!
        filterView.isHidden = false
        emojiesMainView.isHidden = false
        editableTextFieldView.isHidden = false
        btnEmoji.isEnabled = true
        btnLocation.isHidden = false
        btnText.isHidden = false
        if (!isForPost){
            txtFieldCaption.isHidden = false
        }
        btnClock.isHidden = false
        btnTag.isHidden = false
        lblLive.isHidden = true
        lblNormal.isHidden = true
        lblVideo.isHidden = true
        btnRotate.isEnabled = false
        btnFlash.isEnabled = false
        changeView(isVideoSelected: false)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            DispatchQueue.main.async {
                self.captureAnimationImg.isHidden = true
                self.btnCapture.alpha = 1
                self.shouldSaveToGallery = true
                if let videoScreenShot = Utility.imageFromVideo(url: outputFileURL, at: 0, totalTime: 60){
                    self.videoURL = outputFileURL
                    self.isPictureCaptured = true
                    self.cameraView.isHidden = false
                    self.cameraView.contentMode = .scaleAspectFit
                    self.selectedImage = videoScreenShot
                    self.cameraView.image = videoScreenShot
                    self.filterView.isHidden = false
                    self.emojiesMainView.isHidden = false
                    self.editableTextFieldView.isHidden = false
                    self.btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
                    self.btnGallery.setImage(UIImage(named: "colors"), for: .normal)
                    self.btnBack.setImage(UIImage(named: "close-1"), for: .normal)
                    self.lblLive.isHidden = true
                    self.lblNormal.isHidden = true
                    self.lblVideo.isHidden = true
                    self.changeView(isVideoSelected: true)
                    self.addVideoPlayer(videoUrl: self.videoURL, to: self.cameraView)
                    
                }
            }
        }
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if (gestureRecognizer.state == .changed){
            deleteIcon.isHidden = false
        }
        else{
            deleteIcon.isHidden = true
        }
        
        if (gestureRecognizer.view!.isKind(of: UITextView.self)){
           // fontSlider.isHidden = true
            colorSlider.isHidden = true
            lblFont.isHidden = true
        }
        
        //let translation = gestureRecognizer.translation(in: self.filterView)
        let translation = gestureRecognizer.translation(in: self.m_overlayView)
        
        
        gestureRecognizer.setTranslation(CGPoint.zero, in: self.m_overlayView)
        if (gestureRecognizer.view! == timeView)
        {
            timeViewCenterXConstraint.constant += translation.x
            timeViewCenterYConstraint.constant += translation.y
        }
        else if (gestureRecognizer.view! == locationView)
        {
            locationViewCenterXConstraint.constant += translation.x
            locationViewCenterYConstraint.constant += translation.y
        }
        else if (gestureRecognizer.view! == editableTextField)
        {
            editableTextViewCenterYConstraint.constant += translation.y
            editableTextViewCenterXConstraint.constant += translation.x
        }
        else
        {
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
        }
        if ((deleteView.frame.intersects(gestureRecognizer.view!.frame))){
            deleteIcon.image = UIImage(named: "delete-selected")
            gestureRecognizer.view?.alpha = 0.6
            if (gestureRecognizer.state == .ended){
                if (gestureRecognizer.view!.isKind(of: UITextView.self)){
                    editableTextField.text = ""
                    editableTextField.isHidden = true
                    editableTextField.alpha = 1
                    selectedFont = ""
                    lblFont.text = fontsNames.first!
                    lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames.first!, size: 20)
                    editableTextField.font = Theme.getLatoBoldFontOfSize(size: 30)
                    editableTextField.textColor = .white
                }
                else if (gestureRecognizer.view! == timeView){
                    timeView.isHidden = true
                    timeView.alpha = 1
                    timeView.frame = timeViewFrame
                    timeViewCenterXConstraint.constant = 0
                    timeViewCenterYConstraint.constant = 0
                    timeViewStyle = 0
                }
                else if (gestureRecognizer.view! == locationView){
                    locationView.isHidden = true
                    locationView.alpha = 1
                    locationView.frame = locationViewFrame
                    locationViewCenterXConstraint.constant = 0
                    locationViewCenterYConstraint.constant = 0
                    locationViewStyle = 0
                }
                else{
                    gestureRecognizer.view?.removeFromSuperview()
                    deleteIcon.isHidden = true
                    deleteIcon.image = UIImage(named: "delete")
                }
                
            }
            
        }
        else{
            deleteIcon.image = UIImage(named: "delete")
            gestureRecognizer.view?.alpha = 1
        }

    }

    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {

        if let view = pinch.view {
            view.transform = view.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
    }

    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @objc func swipeLeft(_ gesture: UISwipeGestureRecognizer){
        if (selectedFilter < filters.count - 1){
            selectedFilter += 1
            changeImageFilter()
        }
    }
    
    @objc func swipeRight(_ gesture: UISwipeGestureRecognizer){
        if (selectedFilter > 0){
            selectedFilter -= 1
            changeImageFilter()
        }
    }
    
    func changeFilter(){
        if (selectedFilter < filters.count - 1){
            selectedFilter += 1
        }
        else{
            selectedFilter = 0
        }
        changeImageFilter()
    }
    
    func changeImageFilter(){
        if (selectedFilter == 0){
            cameraView.image = selectedImage
        }
        else{
            let image = selectedImage
            let filteredImage = image.addFilter(filter: filters[selectedFilter])
            cameraView.image = filteredImage
        }
    }
    
    //MARK:- Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        isBackTapped = true
        if (self.player != nil){
            self.player.pause()
        }
        if (isPictureCaptured){
            captureAnimationImg.isHidden = true
            btnCapture.alpha = 1
            isPictureCaptured = false
            filterView.isHidden = true
            emojiesMainView.isHidden = true
            editableTextFieldView.isHidden = true
            cameraView.isHidden = true
            cameraView.image = nil
            btnBack.setImage(UIImage(named: "back-1"), for: .normal)
            btnGallery.setImage(UIImage(named: "gallery"), for: .normal)
            btnCapture.setImage(UIImage(named: "capture"), for: .normal)
            btnRotate.isEnabled = true
            btnFlash.isEnabled = true
            btnLocation.isHidden = true
            btnText.isHidden = true
            txtFieldCaption.isHidden = true
            btnClock.isHidden = true
            btnTag.isHidden = true
            btnEmoji.isEnabled = false
            timeView.isHidden = true
            locationView.isHidden = true
            editableTextField.isHidden = true
            editableTextField.text = ""
            lblVideo.isHidden = false
            lblNormal.isHidden = false
          //  lblLive.isHidden = false
            btnPlay.isHidden = true
            btnGallery.isHidden = false
            btnEmoji.isHidden = false
            btnRotate.isHidden = false
            btnFlash.isHidden = false
            editableTextField.text = ""
            colorSlider.isHidden = true
            tagUsersString = ""
            tagUsersArrray.removeAll()
            lblUserTags.text = ""
            lblUserTags.isHidden = true
           // fontSlider.isHidden = true
            lblFont.isHidden = true
            
            //lblNormalTapped()
            for emojiView in emojiesMainView.subviews{
                if (emojiView == editableTextField || emojiView == editableTextFieldView){
                    
                }
                else{
                    emojiView.removeFromSuperview()
                }
                
            }
            for subView in filterView.subviews{
                if (subView == cameraView || subView == timeView || subView == editableTextField || subView == locationView || subView == emojiesMainView || subView == editableTextFieldView || subView == m_overlayView){
                    
                }
                else{
                    subView.removeFromSuperview()
                }
            }
            setZoomFactor(scale: 1.0)
        }
        else{
            setZoomFactor(scale: 1.0)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnCaptureTapped(_ sender: UIButton) {
        if (!isPictureCaptured){
            if (!isLive && !isVideo){
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                settings.flashMode = flashMode//isFrontCamera ? .off : flashMode
                stillImageOutput.capturePhoto(with: settings, delegate: self)
                isPictureCaptured = true
                btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
                btnGallery.setImage(UIImage(named: "colors"), for: .normal)
                btnBack.setImage(UIImage(named: "close-1"), for: .normal)
            }
        }
        else{
            if (self.videoURL == nil){
                self.storyImageToSend = self.filterView.screenshot()
            }
            if (videoURL != nil){
                convertVideoAndSaveTophotoLibrary(videoURL: videoURL!)
            }
            else{
                if (self.isForPost){
                    if (self.player != nil){
                        self.player.pause()
                    }
                    self.dismiss(animated: true, completion: nil)
                    if (self.videoURL == nil){
                        self.delegate.getStoryImage(image: self.storyImageToSend, caption: "", isToSendMyStory: true, friendsArray: [], selectedTagsUserString: self.tagUsersString, selectedTagUsersArray: self.tagUsersArrray)
                    }
                    else{
                        self.delegate.getStoryVideo(videoURL: self.finalEditedVideoURL, caption: "", isToSendMyStory: true, friendsArray: [], selectedTagsUserString: self.tagUsersString, selectedTagUsersArray: self.tagUsersArrray)
                    }
                }
                else{
                    let vc = Utility.getShareStoriesViewController()
                    vc.delegate = self
                    self.pushToVC(vc: vc)
                }
            }
            
        }
        
    }
    
    @IBAction func btnPlayVideoTapped(_ sender: UIButton){
        let player = AVPlayer(url: videoURL);
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func btnGalleryTapped(_ sender: UIButton) {
        if (isPictureCaptured){
            changeFilter()
        }
        else{
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnFlashTapped(_ sender: UIButton) {
        
        if (flashMode == .off){
            flashMode = .on
            torchMode = .on
            btnFlash.setImage(UIImage(named: "flash-1"), for: .normal)
        }
        else if (flashMode == .on){
            flashMode = .auto
            torchMode = .auto
            btnFlash.setImage(UIImage(named: "flash_auto"), for: .normal)
        }
        else if (flashMode == .auto){
            flashMode = .off
            torchMode = .off
            btnFlash.setImage(UIImage(named: "flash_off-1"), for: .normal)
        }
    }
    
    @IBAction func btnLocationTapped(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func btnClockTapped(_ sender: UIButton){
        lblTime.text = Utility.getCurrentTime()
        timeView.isHidden = false
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        gestureRecognizer.require(toFail: timeViewTapGesture)
        timeView.gestureRecognizers?.removeAll()
        timeView.addGestureRecognizer(gestureRecognizer)

        //add pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
        timeView.addGestureRecognizer(pinchGesture)

        //add rotate gesture.
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        timeView.addGestureRecognizer(rotate)
        
    }
    
    @IBAction func btnTextTapped(_ sender: UIButton) {
        editableTextField.isHidden = false
        colorSlider.isHidden = false
        lblFont.isHidden = false
        editableTextField.becomeFirstResponder()
    }
    
    @IBAction func btnEmojiTapped(_ sender: UIButton){
        let vc = Utility.getEmojisViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnRotateTapped(_ sender: UIButton) {
        rotateCamera()
    }
    
    @IBAction func btnTagTapped(_ sender: UIButton){
        let vc = Utility.getAddMembersViewController()
        vc.delegate = self
        vc.isForTagging = true
        vc.selectedUsersIds = self.tagUsersArrray.map{$0.userId}
        self.pushToVC(vc: vc)
    }
    
    @IBAction func fontSliderValueChanged(_ sender: UISlider) {
        fontSize = sender.value.rounded()
        editableTextField.font = selectedFont == "" ? Theme.getLatoBoldFontOfSize(size: CGFloat(fontSize)) : Theme.getPictureEditFonts(fontName: selectedFont, size: CGFloat(fontSize))
    }
    
    @objc func rotateCamera(){
        if let session = captureSession {
            //Remove existing input
            //            guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
            //                return
            //            }
            
            //Indicate that some changes will be made to the session
            session.beginConfiguration()
            for input in session.inputs{
                session.removeInput(input)
            }
            
            //Get new input
            var newCamera: AVCaptureDevice! = nil
            
            if (!isFrontCamera) {
                newCamera = cameraWithPosition(position: .front)
                session.sessionPreset = .high
                isFrontCamera = true
                btnFlash.isEnabled = false
            } else {
                newCamera = cameraWithPosition(position: .back)
                session.sessionPreset = .photo
                isFrontCamera = false
                btnFlash.isEnabled = true
            }
            
            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let err1 as NSError {
                err = err1
                newVideoInput = nil
            }
            
            if newVideoInput == nil || err != nil {
                print("Error creating capture device input: \(err?.localizedDescription)")
            } else {
                if let microphone = AVCaptureDevice.default(for: AVMediaType.audio){
                    do {
                        let micInput = try AVCaptureDeviceInput(device: microphone)
                        if session.canAddInput(micInput) {
                            session.addInput(micInput)
                        }
                    } catch {
                        print("Error setting device audio input: \(error)")
                    }
                }
                session.addInput(newVideoInput)
            }
            
            session.commitConfiguration()
        }

    }
    
    func OnTappRecording(){
        
        var device : AVCaptureDevice!
        if (isFrontCamera)
        {
            device = cameraWithPosition(position: .front)
        }
        else
        {
            device = cameraWithPosition(position: .back)
        }
        
        if (!isPictureCaptured){
            if (!isLive && !isVideo){
                captureAnimationImg.isHidden = true
                btnCapture.alpha = 1
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                settings.flashMode = isFrontCamera ? .off : flashMode
                stillImageOutput.capturePhoto(with: settings, delegate: self)
                isPictureCaptured = true
                btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
                btnGallery.setImage(UIImage(named: "colors"), for: .normal)
                btnBack.setImage(UIImage(named: "close-1"), for: .normal)
            }
            else if (isVideo){
                if isStartedRecording {
                    isStartedRecording = false
                    captureAnimationImg.isHidden = true
                    btnCapture.alpha = 1
                    movieOutput.stopRecording()
                    
                    if (device.hasTorch && device.hasFlash ){
                        do {
                            try device.lockForConfiguration()
                            defer { device.unlockForConfiguration() }
                            device.torchMode = .off
                        } catch {
                            print("\(error.localizedDescription)")
                        }
                    }
                    
                    timer.invalidate()
                    seconds = 0
                    self.lblVideoTimer.text = ""
                    self.recordingIcon.isHidden = true
                    btnRotate.isHidden = false
                }
                else {
                    isStartedRecording = true
                    captureAnimationImg.isHidden = false
                    btnCapture.alpha = 0
                    btnRotate.isHidden = true
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let fileUrl = paths[0].appendingPathComponent("output.mov")
                    try? FileManager.default.removeItem(at: fileUrl)
                    
                    if (device.hasTorch && device.hasFlash )
                    {
                        do {
                            try device.lockForConfiguration()
                            defer { device.unlockForConfiguration() }
                            device.torchMode = torchMode
                            
                        } catch {
                            print("\(error.localizedDescription)")
                        }
                    }
                    
                    movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
                    
                    self.runTimer()
                }
            }
        }
        else{
            captureAnimationImg.isHidden = true
            btnCapture.alpha = 1
            if (self.player != nil){
                self.player.pause()
            }
            if (self.videoURL == nil){
                self.storyImageToSend = self.filterView.screenshot()
            }
            if (isForPost){
                self.dismiss(animated: true, completion: nil)
                if (self.videoURL == nil){
                    self.delegate.getStoryImage(image: self.storyImageToSend, caption: "", isToSendMyStory: true, friendsArray: [], selectedTagsUserString: tagUsersString, selectedTagUsersArray: tagUsersArrray)
                }
                else{
                    self.delegate.getStoryVideo(videoURL: self.videoURL, caption: "", isToSendMyStory: true, friendsArray: [], selectedTagsUserString: tagUsersString, selectedTagUsersArray: tagUsersArrray)
                }
            }
            else{
                let vc = Utility.getShareStoriesViewController()
                vc.delegate = self
                self.pushToVC(vc: vc)
            }
        }
    }
    
    @objc func lblFontsTapped(){
        if (lblFont.text == fontsNames[0]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[0], size: CGFloat(fontSize))
            selectedFont = fontsNames[0]
            lblFont.text = fontsNames[1]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[1], size: 20)
        }
        else if (lblFont.text == fontsNames[1]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[1], size: CGFloat(fontSize))
            selectedFont = fontsNames[1]
            lblFont.text = fontsNames[2]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[2], size: 20)
        }
        else if (lblFont.text == fontsNames[2]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[2], size: CGFloat(fontSize))
            selectedFont = fontsNames[2]
            lblFont.text = fontsNames[3]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[3], size: 20)
        }
        else if (lblFont.text == fontsNames[3]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[3], size: CGFloat(fontSize))
            selectedFont = fontsNames[3]
            lblFont.text = fontsNames[4]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[4], size: 20)
        }
        else if (lblFont.text == fontsNames[4]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[4], size: CGFloat(fontSize))
            selectedFont = fontsNames[4]
            lblFont.text = fontsNames[5]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[5], size: 20)
        }
        else if (lblFont.text == fontsNames[5]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[5], size: CGFloat(fontSize))
            selectedFont = fontsNames[5]
            lblFont.text = fontsNames[6]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[6], size: 20)
        }
        else if (lblFont.text == fontsNames[6]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[6], size: CGFloat(fontSize))
            selectedFont = fontsNames[6]
            lblFont.text = fontsNames[7]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[7], size: 20)
        }
        else if (lblFont.text == fontsNames[7]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[7], size: CGFloat(fontSize))
            selectedFont = fontsNames[7]
            lblFont.text = fontsNames[8]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[8], size: 20)
        }
        else if (lblFont.text == fontsNames[8]){
            editableTextField.font = Theme.getPictureEditFonts(fontName: fontsNames[8], size: CGFloat(fontSize))
            selectedFont = fontsNames[8]
            lblFont.text = fontsNames[0]
            lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames[0], size: 20)
        }
    }
    
    @objc func editableTextFieldTapped(){
        colorSlider.isHidden = false
        lblFont.isHidden = false
       // fontSlider.isHidden = false
    }
    
    @objc func editableTextFieldRotate(recognizer: UIRotationGestureRecognizer){
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
          //  recognizer.rotation = 0
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        seconds += 1
        self.lblVideoTimer.text = timeString(time: TimeInterval(seconds))
        self.recordingIcon.isHidden = false
        if (seconds == (60/*isForPost ? 60 : 15*/)){
            timer.invalidate()
            seconds = 0
            self.lblVideoTimer.text = ""
            self.recordingIcon.isHidden = true
            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }

    func playVideo() {
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
        print("playing...")
    }
}

extension CameraViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension CameraViewController: EmojisViewControllerDelegate{
    func emojiTapped(image: UIImage, isEmojis: Bool) {
        var width: CGFloat = 0.0
        if (isEmojis){
            width = 90
        }
        else{
            width = (UIScreen.main.bounds.width - 30) / 3
        }
        let imageView = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 40, y: (UIScreen.main.bounds.height / 4), width: width, height: isEmojis ? 90 : 110))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        emojiesMainView.addSubview(imageView)
       
        imageView.isUserInteractionEnabled = true

        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
                gestureRecognizer.delegate = self
                imageView.gestureRecognizers?.removeAll()
                imageView.addGestureRecognizer(gestureRecognizer)

                //add pinch gesture
                let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
                pinchGesture.delegate = self
                imageView.addGestureRecognizer(pinchGesture)

                //add rotate gesture.
                let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
                rotate.delegate = self
                imageView.addGestureRecognizer(rotate)
        
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        captureAnimationImg.isHidden = true
        btnCapture.alpha = 1
        picker.dismiss(animated: true, completion: nil)
        self.shouldSaveToGallery = false
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            isPictureCaptured = true
            
            if (image.size.width > image.size.height){
                cameraView.contentMode = .scaleAspectFit
            }
            else{
                cameraView.contentMode = .scaleAspectFit//.scaleAspectFill
            }
            cameraView.isHidden = false
            selectedImage = image
            cameraView.image = image
            filterView.isHidden = false
            emojiesMainView.isHidden = false
            editableTextFieldView.isHidden = false

            btnEmoji.isEnabled = true
            btnLocation.isHidden = false
            btnText.isHidden = false
            if (!isForPost){
                txtFieldCaption.isHidden = false
            }
            btnClock.isHidden = false
            btnTag.isHidden = false
            btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
            btnGallery.setImage(UIImage(named: "colors"), for: .normal)
            btnBack.setImage(UIImage(named: "close-1"), for: .normal)
            lblLive.isHidden = true
            lblNormal.isHidden = true
            lblVideo.isHidden = true
            btnRotate.isEnabled = false
            btnFlash.isEnabled = false
            
        }
        
        if let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            DispatchQueue.main.async {
                if let videoScreenShot = Utility.imageFromVideo(url: video, at: 0, totalTime: 60){
                    self.videoURL = video
                    self.isPictureCaptured = true
                    self.cameraView.isHidden = false
                    self.cameraView.contentMode = .scaleAspectFit
                    self.selectedImage = videoScreenShot
                    self.cameraView.image = videoScreenShot
                    self.filterView.isHidden = false
                    self.emojiesMainView.isHidden = false
                    self.editableTextFieldView.isHidden = false
                    self.btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
                    self.btnGallery.setImage(UIImage(named: "colors"), for: .normal)
                    self.btnBack.setImage(UIImage(named: "close-1"), for: .normal)
                    self.lblLive.isHidden = true
                    self.lblNormal.isHidden = true
                    self.lblVideo.isHidden = true
                    self.changeView(isVideoSelected: true)
                    self.addVideoPlayer(videoUrl: self.videoURL, to: self.cameraView)
                }
            }

        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        captureAnimationImg.isHidden = true
        btnCapture.alpha = 1
        self.dismiss(animated: true, completion: nil)
        lblNormalTapped()
    }
}

extension CameraViewController: UITextViewDelegate{
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.text == ""){
          //  fontSlider.isHidden = true
            colorSlider.isHidden = true
            lblFont.isHidden = true
            editableTextField.isHidden = true
        }
        else{

            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
                    gestureRecognizer.delegate = self
                    editableTextField.gestureRecognizers?.removeAll()
                    editableTextField.addGestureRecognizer(gestureRecognizer)

                    //Enable multiple touch and user interaction for textfield
                    editableTextField.isUserInteractionEnabled = true
                    editableTextField.isMultipleTouchEnabled = true

                    //add pinch gesture
                    let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
                    pinchGesture.delegate = self
                    editableTextField.addGestureRecognizer(pinchGesture)

                    //add rotate gesture.
                    let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
                    rotate.delegate = self
                    editableTextField.addGestureRecognizer(rotate)
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        timeView.frame = timeView.frame
        locationView.frame = locationView.frame
        return true
    }
}

extension CameraViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            // If the gesture recognizer's view isn't one of the squares, do not
            // allow simultaneous recognition.
            if (gestureRecognizer is InstantPanGestureRecognizer)
            {
                print("Pan Gesture")
            }
            else if (gestureRecognizer is UILongPressGestureRecognizer)
            {
                print("Long Gesture")
            }
            return true
    }
}

extension CameraViewController: GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        if let placeName = place.name{
            lblLocation.text = placeName
            locationView.isHidden = false
    
            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            gestureRecognizer.delegate = self
            gestureRecognizer.require(toFail: locationViewTapGesture)
            locationView.gestureRecognizers?.removeAll()
            locationView.addGestureRecognizer(gestureRecognizer)

            //add pinch gesture
            let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
            pinchGesture.delegate = self
            locationView.addGestureRecognizer(pinchGesture)

            //add rotate gesture.
            let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
            rotate.delegate = self
            locationView.addGestureRecognizer(rotate)
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CameraViewController: ShareStoriesViewControllerDelegate{
    func shareStoryToMyStoryAndFriends(isToSendMyStory: Bool, friendsArray: [RecentChatsModel]) {
        if (self.videoURL == nil){
            
            if (isToSendMyStory && shouldSaveToGallery){
                UIImageWriteToSavedPhotosAlbum(storyImageToSend, self, nil, nil)
            }
            self.delegate.getStoryImage(image: storyImageToSend, caption: self.txtFieldCaption.text!, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray, selectedTagsUserString: tagUsersString, selectedTagUsersArray: tagUsersArrray)
        }
        else{
//            if (isToSendMyStory && shouldSaveToGallery){
//                PHPhotoLibrary.shared().performChanges({
//                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
//                }) { saved, error in
//                    if saved {
//                    }
//                }
//            }
            
            self.delegate.getStoryVideo(videoURL: self.finalEditedVideoURL, caption: txtFieldCaption.text!, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray, selectedTagsUserString: tagUsersString, selectedTagUsersArray: tagUsersArrray)
        }
        if (player != nil){
            player.pause()
        }
        self.dismiss(animated: true, completion: nil)

    }
}

extension CameraViewController: AddMembersViewControllerDelegate{
    
    func membersAdded(membersArray: [PostLikesUserModel]) {
        
        self.tagUsersArrray = membersArray
        tagUsersString = ""
        for tagUser in self.tagUsersArrray{
            if (tagUsersString == ""){
                tagUsersString = "@\(tagUser.userFullName)"
            }
            else{
                tagUsersString = tagUsersString + ", " + "@\(tagUser.userFullName)"
            }
        }
        lblUserTags.isHidden = false
        lblUserTags.text = tagUsersString
        
    }
    
}

// MARK: - OTSessionDelegate callbacks
extension CameraViewController: OTSessionDelegate {
   func sessionDidConnect(_ session: OTSession) {
       print("The client connected to the OpenTok session.")
        
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        guard let publisher = OTPublisher(delegate: self, settings: settings) else {
            return
        }

        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }

        guard let publisherView = publisher.view else {
            return
        }
        let screenBounds = UIScreen.main.bounds
        publisherView.frame = cameraView.frame
        view.addSubview(publisherView)
    
   }

   func sessionDidDisconnect(_ session: OTSession) {
       print("The client disconnected from the OpenTok session.")
   }

   func session(_ session: OTSession, didFailWithError error: OTError) {
       print("The client failed to connect to the OpenTok session: \(error).")
   }

   func session(_ session: OTSession, streamCreated stream: OTStream) {
       print("A stream was created in the session.")
    
        subscriber = OTSubscriber(stream: stream, delegate: self)
        guard let subscriber = subscriber else {
            return
        }

        var error: OTError?
        session.subscribe(subscriber, error: &error)
        guard error == nil else {
            print(error!)
            return
        }

        guard let subscriberView = subscriber.view else {
            return
        }
        subscriberView.frame = UIScreen.main.bounds
        view.insertSubview(subscriberView, at: 0)
    
   }

   func session(_ session: OTSession, streamDestroyed stream: OTStream) {
       print("A stream was destroyed in the session.")
   }
}

// MARK: - OTPublisherDelegate callbacks
extension CameraViewController: OTPublisherDelegate {
   func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
       print("The publisher failed: \(error)")
   }
}

// MARK: - OTSubscriberDelegate callbacks
extension CameraViewController: OTSubscriberDelegate {
   public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
       print("The subscriber did connect to the stream.")
   }

   public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
       print("The subscriber failed to connect to the stream.")
   }
}
