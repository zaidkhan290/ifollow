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

protocol CameraViewControllerDelegate: class {
    func getStoryImage(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel])
    func getStoryVideo(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel])
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
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var txtFieldCaption: UITextField!
    @IBOutlet weak var lblVideoTimer: UILabel!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput: AVCaptureMovieFileOutput!
    var flashMode = AVCaptureDevice.FlashMode.off
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
    
    var timer = Timer()
    var seconds = 0
    
    var storyImageToSend = UIImage()
    
    var isForPost = false
    var shouldSaveToGallery = false

    
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
        
//        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpToGetStickers))
//        swipeUpGesture.direction = .up
//        self.view.addGestureRecognizer(swipeUpGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //----- For AVCaptureSession Start-----//
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1280x720
       // captureSession.automaticallyConfiguresApplicationAudioSession = false
    
        captureSession.usesApplicationAudioSession = true
        
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
    
    @objc func swipeUpToGetStickers(){
        let vc = Utility.getEmojisViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func changeView(isVideoSelected: Bool){
        btnGallery.isHidden = isVideoSelected
        btnEmoji.isHidden = isVideoSelected
        btnText.isHidden = isVideoSelected
        btnLocation.isHidden = isVideoSelected
        btnFlash.isHidden = isVideoSelected
        btnRotate.isHidden = isVideoSelected
        btnPlay.isHidden = !isVideoSelected
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
        
        shouldSaveToGallery = true
        let image = UIImage(data: imageData)
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
        
        let translation = gestureRecognizer.translation(in: self.filterView)
        
        gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
        gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        
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
                    timeViewStyle = 0
                }
                else if (gestureRecognizer.view! == locationView){
                    locationView.isHidden = true
                    locationView.alpha = 1
                    locationView.frame = locationViewFrame
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
        if (isPictureCaptured){
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
           // fontSlider.isHidden = true
            lblFont.isHidden = true
            lblNormalTapped()
            for emojiView in emojiesMainView.subviews{
                if (emojiView == editableTextField || emojiView == editableTextFieldView){
                    
                }
                else{
                    emojiView.removeFromSuperview()
                }
                
            }
            for subView in filterView.subviews{
                if (subView == cameraView || subView == timeView || subView == editableTextField || subView == locationView || subView == emojiesMainView || subView == editableTextFieldView){
                    
                }
                else{
                    subView.removeFromSuperview()
                }
            }
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnCaptureTapped(_ sender: UIButton) {
        if (!isPictureCaptured){
            if (!isLive && !isVideo){
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                settings.flashMode = isFrontCamera ? .off : flashMode
                stillImageOutput.capturePhoto(with: settings, delegate: self)
                isPictureCaptured = true
                btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
                btnGallery.setImage(UIImage(named: "colors"), for: .normal)
                btnBack.setImage(UIImage(named: "close-1"), for: .normal)
            }
            else if (isVideo){
                if movieOutput.isRecording {
                    movieOutput.stopRecording()
                    timer.invalidate()
                    seconds = 0
                    self.lblVideoTimer.text = ""
                    btnRotate.isHidden = false
                }
                else {

                    btnRotate.isHidden = true
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let fileUrl = paths[0].appendingPathComponent("output.mov")
                    try? FileManager.default.removeItem(at: fileUrl)
                    movieOutput.startRecording(to: fileUrl, recordingDelegate: self)

                    self.runTimer()
                }
            }
        }
        else{
            if (self.videoURL == nil){
                self.storyImageToSend = self.filterView.screenshot()
            }
            if (isForPost){
                self.dismiss(animated: true, completion: nil)
                if (self.videoURL == nil){
                    self.delegate.getStoryImage(image: self.storyImageToSend, caption: "", isToSendMyStory: true, friendsArray: [])
                }
                else{
                    self.delegate.getStoryVideo(videoURL: self.videoURL, caption: "", isToSendMyStory: true, friendsArray: [])
                }
            }
            else{
                let vc = Utility.getShareStoriesViewController()
                vc.delegate = self
                self.pushToVC(vc: vc)
            }
        }
        
    }
    
    @IBAction func btnPlayVideoTapped(_ sender: UIButton){
        let player = AVPlayer(url: videoURL)
        
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
            btnFlash.setImage(UIImage(named: "flash-1"), for: .normal)
        }
        else if (flashMode == .on){
            flashMode = .auto
            btnFlash.setImage(UIImage(named: "flash_auto"), for: .normal)
        }
        else if (flashMode == .auto){
            flashMode = .off
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
                session.sessionPreset = .hd1280x720
                isFrontCamera = true
                btnFlash.isEnabled = false
            } else {
                newCamera = cameraWithPosition(position: .back)
                session.sessionPreset = .high
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
    
    @IBAction func fontSliderValueChanged(_ sender: UISlider) {
        fontSize = sender.value.rounded()
        editableTextField.font = selectedFont == "" ? Theme.getLatoBoldFontOfSize(size: CGFloat(fontSize)) : Theme.getPictureEditFonts(fontName: selectedFont, size: CGFloat(fontSize))
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
        if (seconds == (60/*isForPost ? 60 : 15*/)){
            timer.invalidate()
            seconds = 0
            self.lblVideoTimer.text = ""
            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let seconds = Int(time) % 60
        return String(format:"%02i",seconds)
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
                }
            }

        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
            self.delegate.getStoryImage(image: storyImageToSend, caption: self.txtFieldCaption.text!, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
        }
        else{
            if (isToSendMyStory && shouldSaveToGallery){
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
                }) { saved, error in
                    if saved {
                    }
                }
            }
            
            self.delegate.getStoryVideo(videoURL: self.videoURL, caption: txtFieldCaption.text!, isToSendMyStory: isToSendMyStory, friendsArray: friendsArray)
        }
        self.dismiss(animated: true, completion: nil)

    }
}

