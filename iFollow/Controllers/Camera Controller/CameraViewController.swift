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

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cameraView: UIImageView!
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
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var editableTextField: UITextField!
    @IBOutlet weak var fontSlider: UISlider!
    @IBOutlet weak var lblFont: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var clockIcon: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isFlashOn = false
    var isFrontCamera = false
    var isPictureCaptured = false
    var emojis = [UIImage]()
    var imagePicker = UIImagePickerController()
    var isLive = false
    var colorSlider: ColorSlider!
    var fontSize: Float = 30.0
    var selectedFont = ""
    var timeViewFrame: CGRect!
    var timeViewStyle = 1 // 1 for Yellow, 2 for unfill, 3 for white
    var timeViewTapGesture = UITapGestureRecognizer()
    var fontsNames = ["Rightland", "LemonMilk", "Cream", "Gobold", "Janda", "Poetsen", "Simplisicky", "Evogria", "Yellosun"]
    let filters = ["","CIPhotoEffectMono", "CIPhotoEffectChrome", "CIPhotoEffectTransfer", "CIPhotoEffectInstant", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectFade"]
    var selectedFilter = 0
    var selectedImage = UIImage()
    
  //  let filterSwipeView = DSSwipableFilterView(frame: UIScreen.main.bounds)
    
//    let filterList = [DSFilter(name: "No Filter", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectMono", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectChrome", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectTransfer", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectInstant", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectNoir", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectProcess", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectTonal", type: .ciFilter),
//                      DSFilter(name: "CIPhotoEffectFade", type: .ciFilter)]
    
    //MARK:- Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ranges = [0x1F601...0x1F64F /*, 0x2702...0x27B0*/]
        emojis = ranges
            .flatMap { $0 }
            .compactMap { Unicode.Scalar($0) }
            .map(Character.init)
            .compactMap { String($0).image() }
        
     //   prepareFilterView()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        editableTextField.delegate = self
        
        btnEmoji.isEnabled = false
        btnLocation.isHidden = true
        btnText.isHidden = true
        btnClock.isHidden = true
        
        lblLive.isUserInteractionEnabled = true
        lblLive.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lblLiveTapped)))
        lblNormal.isUserInteractionEnabled = true
        lblNormal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lblNormalTapped)))
        
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
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeftGesture.direction = .left
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRightGesture.direction = .right
        
        self.filterView.addGestureRecognizer(swipeLeftGesture)
        self.filterView.addGestureRecognizer(swipeRightGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
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
    
    @objc func colorSliderValueChanged(_ slider: ColorSlider) {
        let color = slider.color
        editableTextField.textColor = color
    }

    @objc func lblLiveTapped(){
        isLive = true
        lblLive.font = Theme.getLatoBoldFontOfSize(size: 18)
        lblNormal.font = Theme.getLatoRegularFontOfSize(size: 15)
    }
    
    @objc func lblNormalTapped(){
        isLive = false
        lblNormal.font = Theme.getLatoBoldFontOfSize(size: 18)
        lblLive.font = Theme.getLatoRegularFontOfSize(size: 15)
    }
    
    @objc func timeViewTapped(){
        if (timeViewStyle == 1){
            timeViewStyle = 2
        }
        else if (timeViewStyle == 2){
            timeViewStyle = 3
        }
        else if (timeViewStyle == 3){
            timeViewStyle = 1
        }
        changeTimeViewStyle()
    }
    
    @objc func changeTimeViewStyle(){
        if (timeViewStyle == 1){
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
    
//    fileprivate func prepareFilterView() {
//        filterSwipeView.dataSource = self
//        filterSwipeView.isUserInteractionEnabled = true
//        filterSwipeView.isMultipleTouchEnabled = true
//        filterSwipeView.isExclusiveTouch = false
//        self.filterView.addSubview(filterSwipeView)
//        filterSwipeView.reloadData()
//    }
    
//    fileprivate func preview(image: UIImage) {
//        filterSwipeView.setRenderImage(image: image)
//    }
    
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
    
    func toggleTorch(on: Bool) {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
            else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        cameraView.isHidden = false
        selectedImage = image!
        cameraView.image = image!
        filterView.isHidden = false
//        filterSwipeView.isPlayingLibraryVideo = true
        btnEmoji.isEnabled = true
        btnLocation.isHidden = false
        btnText.isHidden = false
        btnClock.isHidden = false
        lblLive.isHidden = true
        lblNormal.isHidden = true
        btnRotate.isEnabled = false
        btnFlash.isEnabled = false
        toggleTorch(on: false)
      //  preview(image: image!)
    }
    
    @objc func setDragging(_ sender:UIPanGestureRecognizer){
        
        if (sender.state == .changed){
            deleteIcon.isHidden = false
        }
        else{
            deleteIcon.isHidden = true
        }
        
        if (sender.view!.isKind(of: UITextField.self)){
            fontSlider.isHidden = true
            colorSlider.isHidden = true
            lblFont.isHidden = true
        }
        
//        if (sender.view! == timeView){
//            if (sender.state == .began){
//                timeViewTapped()
//            }
//        }
        
        var rec: CGRect = sender.view!.frame
        let imgvw: CGRect = cameraView.frame
        if rec.origin.y > cameraView.bounds.height{
            rec.origin.y = cameraView.bounds.height
        }
        if rec.origin.x < 0{
            rec.origin.x = 0
        }
        
        if (rec.origin.x >= imgvw.origin.x && (rec.origin.x + rec.size.width <= imgvw.origin.x + imgvw.size.width) && (rec.origin.y >= imgvw.origin.y && (rec.origin.y + rec.size.height <= imgvw.origin.y + imgvw.size.height))) {
            
            let translation: CGPoint = sender.translation(in: sender.view!.superview)
            sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
            rec = (sender.view?.frame)!
            
            if rec.origin.x < imgvw.origin.x {
                rec.origin.x = imgvw.origin.x
            }
            if rec.origin.x + rec.size.width > imgvw.origin.x + imgvw.size.width {
                rec.origin.x = imgvw.origin.x + imgvw.size.width - rec.size.width
            }
            
            if rec.origin.y < imgvw.origin.y{
                rec.origin.y = imgvw.origin.y
            }
            if rec.origin.y + rec.size.height > imgvw.origin.y + imgvw.size.height {
                rec.origin.y = imgvw.origin.y + imgvw.size.height - rec.size.height
            }
            
            sender.view?.frame = rec
            sender.setTranslation(CGPoint.zero, in: sender.view?.superview)
            
            if ((deleteView.frame.intersects(sender.view!.frame))){
                deleteIcon.image = UIImage(named: "delete-selected")
                sender.view?.alpha = 0.6
                if (sender.state == .ended){
                    if (sender.view!.isKind(of: UITextField.self)){
                        editableTextField.text = ""
                        editableTextField.isHidden = true
                        editableTextField.alpha = 1
                        selectedFont = ""
                        lblFont.text = fontsNames.first!
                        lblFont.font = Theme.getPictureEditFonts(fontName: fontsNames.first!, size: 20)
                        editableTextField.font = Theme.getLatoBoldFontOfSize(size: 30)
                        editableTextField.textColor = .white
                    }
                    else if (sender.view! == timeView){
                        timeView.isHidden = true
                        timeView.alpha = 1
                        timeView.frame = timeViewFrame
                        timeViewStyle = 1
                    }
                    else{
                        sender.view?.removeFromSuperview()
                        deleteIcon.isHidden = true
                        deleteIcon.image = UIImage(named: "delete")
                    }
                    
                }
                
            }
            else{
                deleteIcon.image = UIImage(named: "delete")
                sender.view?.alpha = 1
            }
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCaptureTapped(_ sender: UIButton) {
        if (!isPictureCaptured){
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            settings.flashMode = isFlashOn ? .on : .off
            stillImageOutput.capturePhoto(with: settings, delegate: self)
            isPictureCaptured = true
            btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
        }
        else{
            let image = self.filterView.screenshot()
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnGalleryTapped(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnFlashTapped(_ sender: UIButton) {
        if (!isFrontCamera){
            isFlashOn = !isFlashOn
          //  toggleTorch(on: isFlashOn)
        }
        
    }
    
    @IBAction func btnLocationTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnClockTapped(_ sender: UIButton){
        lblTime.text = Utility.getCurrentTime()
        timeView.isHidden = false
        self.filterView.bringSubviewToFront(timeView)
       // self.cameraView.bringSubviewToFront(timeView)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(setDragging(_:)))
        panGesture.delegate = self
        panGesture.require(toFail: timeViewTapGesture)
        timeView.gestureRecognizers?.removeAll()
        timeView.addGestureRecognizer(panGesture)
    }
    
    @IBAction func btnTextTapped(_ sender: UIButton) {
        editableTextField.isHidden = false
        self.filterView.bringSubviewToFront(editableTextField)
       // self.cameraView.bringSubviewToFront(editableTextField)
        colorSlider.isHidden = false
        lblFont.isHidden = false
        fontSlider.isHidden = false
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
            guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
                return
            }
            
            //Indicate that some changes will be made to the session
            session.beginConfiguration()
            session.removeInput(currentCameraInput)
            
            //Get new input
            var newCamera: AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if (input.device.position == .back) {
                    newCamera = cameraWithPosition(position: .front)
                    isFrontCamera = true
                    isFlashOn = false
                } else {
                    newCamera = cameraWithPosition(position: .back)
                    isFrontCamera = false
                }
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
        fontSlider.isHidden = false
    }
}

//extension CameraViewController: DSSwipableFilterViewDataSource {
//
//    func numberOfFilters(_ filterView: DSSwipableFilterView) -> Int {
//        return filterList.count
//    }
//
//    func filter(_ filterView: DSSwipableFilterView, filterAtIndex index: Int) -> DSFilter {
//        return filterList[index]
//    }
//
//    func startAtIndex(_ filterView: DSSwipableFilterView) -> Int {
//        return 0
//    }
//
//}

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
        filterView.addSubview(imageView)
     //   cameraView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(setDragging(_:)))
        panGesture.delegate = self
        imageView.addGestureRecognizer(panGesture)
        imageView.enableZoom()
        
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            isPictureCaptured = true
            cameraView.isHidden = false
            selectedImage = image
            cameraView.image = image
            filterView.isHidden = false
//            filterSwipeView.isPlayingLibraryVideo = true
//            preview(image: image)
            btnEmoji.isEnabled = true
            btnLocation.isHidden = false
            btnText.isHidden = false
            btnClock.isHidden = false
            btnCapture.setImage(UIImage(named: "send-story"), for: .normal)
            lblLive.isHidden = true
            lblNormal.isHidden = true
            btnRotate.isEnabled = false
            btnFlash.isEnabled = false
            toggleTorch(on: false)
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CameraViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField.text == ""){
            fontSlider.isHidden = true
            colorSlider.isHidden = true
            lblFont.isHidden = true
            editableTextField.isHidden = true
        }
        else{
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(setDragging(_:)))
            panGesture.delegate = self
            editableTextField.gestureRecognizers?.removeAll()
            editableTextField.addGestureRecognizer(panGesture)
        }
        
    }
}

extension CameraViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
