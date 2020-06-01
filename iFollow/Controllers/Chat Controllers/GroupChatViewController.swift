//
//  GroupGroupChatViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 14/04/2020.
//  Copyright © 2020 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import Loaf
import DTPhotoViewerController
import AVFoundation
import AVKit

class GroupChatViewController: JSQMessagesViewController, JSQMessageMediaData, JSQAudioMediaItemDelegate {
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var messages = [JSQMessage]()
    var sendButton = UIButton()
    var recordButton = UIButton()
    var chatRef = rootRef
    var groupMediaRef = rootRef
    var storageRef : StorageReference?
    var recordingSession: AVAudioSession!
    var chatId = ""
    var groupModel = GroupChatModel()
//    var userImage = ""
//    var userName = ""
//    var otherUserId = 0
    var timer = Timer()
    var seconds = 1
    var recordingState: RecordingEnum!
    var shouldShowLocalImageMessage = false
    var shouldShowLocalAudioMessage = false
    var shouldShowLocalVideoMessage = false
    var isRecordingCancel = false
    var shouldSendNotification = true
    var videoURL: URL!
    var imagePicker = UIImagePickerController()
    var lastMessageKey = ""
    var isAllMessagesLoad = false
    var messageKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.videoMaximumDuration = 60
        imagePicker.videoQuality = .type640x480
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: Theme.profileLabelsYellowColor)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: Theme.privateChatBoxSearchBarColor)
        
        chatRef = chatRef.child("GroupChats").child(chatId)
        groupMediaRef = groupMediaRef.child("GroupMedia").child(chatId)
        self.inputToolbar.contentView.backgroundColor = .white
        self.inputToolbar.contentView.textView.textColor = .black
        self.inputToolbar.contentView.textView.backgroundColor = .clear
        
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        self.setup()
        self.messageAdded(isFirstTime: true)
        self.inputToolbar.contentView.textView.placeHolder = "Type a message..."
        self.inputToolbar.contentView.textView.layer.borderColor = UIColor.clear.cgColor
        self.inputToolbar.contentView.textView.autocorrectionType = .yes
        
        let rightContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 42))
        
        sendButton = UIButton(frame: CGRect(x: -3, y: -5, width: 40, height: 42  ))
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        rightContainerView.backgroundColor = .clear
        rightContainerView.addSubview(sendButton)
        self.inputToolbar.contentView.rightBarButtonContainerView.addSubview(rightContainerView)
        self.inputToolbar.contentView.rightContentPadding = 0
        
        let leftContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 42))
        
        recordButton = UIButton(frame: CGRect(x: 0, y: -5, width: 60, height: 42  ))
        recordButton.setImage(UIImage(named: "microphone"), for: .normal)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordButtonPressed(gesture:)))
        longPressGesture.minimumPressDuration = 0.2
        longPressGesture.allowableMovement = 0
        longPressGesture.cancelsTouchesInView = false
        recordButton.addGestureRecognizer(longPressGesture)
        leftContainerView.backgroundColor = .clear
        leftContainerView.addSubview(recordButton)
        //   leftContainerView.addSubview(cancelButton)
        self.inputToolbar.contentView.leftBarButtonItemWidth = 40
        self.inputToolbar.contentView.leftBarButtonItem.isHidden = true
        self.inputToolbar.contentView.leftContentPadding = 0
        self.inputToolbar.contentView.leftBarButtonContainerView.addSubview(leftContainerView)
        
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .selected)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .highlighted)
        
        self.inputToolbar.contentView.leftBarButtonItem.setImage(nil, for: .normal)
        self.inputToolbar.contentView.leftBarButtonItem.setImage(nil, for: .selected)
        self.inputToolbar.contentView.leftBarButtonItem.setImage(nil, for: .highlighted)
        
        
        //        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        //        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .selected)
        //        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .highlighted)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showImagePicker), name: NSNotification.Name(rawValue: "imageButtonTapped"), object: nil)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                    } else {
                        
                        Loaf("Could not record audio.", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                            
                        }
                    }
                }
            }
        } catch {
            Loaf("Could not record audio.", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                
            }
        }
        
    } 
    
    func mediaPlaceholderView() -> UIView! {
        
        let viewOfPlace = JSQMessagesMediaPlaceholderView(frame: CGRect(x: 0, y: 0, width: 50.0, height: 50.0), backgroundColor: UIColor.darkText, activityIndicatorView: UIActivityIndicatorView(style: .gray))
        return viewOfPlace
    }
    
    func mediaHash() -> UInt {
        return UInt(50.0)
    }
    
    func mediaView() -> UIView! {
        return UIView()
    }
    
    func mediaViewDisplaySize() -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func setup() {
        self.senderId = "\(Utility.getLoginUserId())"
        self.senderDisplayName = "\(Utility.getLoginUserFullName())"
    }
    
    func load_image(urlString:String) -> UIImage{
        
        let imageView = UIImageView()
        
        if let url = NSURL(string: urlString) {
            imageView.sd_setImage(with: url as URL, placeholderImage: UIImage(named:"img_placeholder"), options: .continueInBackground)
            return imageView.image!
        }
        return UIImage()
    }
    
    func messageAdded(isFirstTime: Bool){
        
        if (isFirstTime){
            chatRef.queryLimited(toLast: 100).observe(.childAdded, with: { (snapshot) in
                self.messageKeys.append(snapshot.key)
                let type = snapshot.childSnapshot(forPath: "type").value as! Int
                let sender = snapshot.childSnapshot(forPath: "senderId").value as! String
                let message = snapshot.childSnapshot(forPath: "message").value as! String
                let user_name = snapshot.childSnapshot(forPath: "senderName").value as! String
                let date = snapshot.childSnapshot(forPath: "timestamp").value as! Double
                let isRead = snapshot.childSnapshot(forPath: "isRead").value as! Bool
                
                if(type == 1){
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date)
                }else if (type == 2){
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date)
                }
                else if (type == 3){
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date)
                    
                }
                else{
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isVideo: true,date: date)
                }
                
            })
        }
        else{
            
            chatRef.queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                let chatNode = snapshot.key
                self.lastMessageKey = snapshot.key
                let userId = (snapshot.childSnapshot(forPath: "senderId").value as! String)
                if (userId != "\(Utility.getLoginUserId())"){
                    let chatToUpdate = self.chatRef.child(chatNode)
                    chatToUpdate.updateChildValues(["isRead": true])
                }
            }
            
            Utility.showOrHideLoader(shouldShow: true)
            chatRef.removeAllObservers()
            self.messages.removeAll()
            self.messageKeys.removeAll()
            
            chatRef.observe(.childAdded, with: { (snapshot) in
                self.messageKeys.append(snapshot.key)
                let type = snapshot.childSnapshot(forPath: "type").value as! Int
                let sender = snapshot.childSnapshot(forPath: "senderId").value as! String
                let message = snapshot.childSnapshot(forPath: "message").value as! String
                let user_name = snapshot.childSnapshot(forPath: "senderName").value as! String
                let date = snapshot.childSnapshot(forPath: "timestamp").value as! Double
                let isRead = snapshot.childSnapshot(forPath: "isRead").value as! Bool
                
                if(type == 1){
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date)
                }else if (type == 2){
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date)
                }
                else if (type == 3){
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date)
                    
                }
                else{
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isVideo: true,date: date)
                }
                
                if (snapshot.key == self.lastMessageKey){
                    Utility.showOrHideLoader(shouldShow: false)
                }
                
            })
        }
        
        chatRef.observe(.childRemoved) { (snapshot) in
            let deleteMessageKey = snapshot.key
            if let indexOfDeleteMessageKey = self.messageKeys.firstIndex(of: deleteMessageKey){
                self.collectionView.deleteItems(at: [IndexPath(row: indexOfDeleteMessageKey, section: 0)])
                self.messageKeys.remove(at: indexOfDeleteMessageKey)
                self.messages.remove(at: indexOfDeleteMessageKey)
                self.collectionView.reloadData()
            }
        }
    }
    
    func addDemoMessages(sender_Id : String, senderName : String, textMsg : String, isImage :Bool?=false, isAudio:Bool?=false, isVideo:Bool?=false, date:Double) {
        
        if(isImage)!{
            
            let activity = UIActivityIndicatorView(style: .gray)
            activity.startAnimating()
            
            let imageView = UIImageView()
            activity.frame = imageView.frame
            imageView.image = nil
            imageView.addSubview(activity)
            
            if(sender_Id == self.senderId){
                if (!self.shouldShowLocalImageMessage){
                    let img2 = JSQPhotoMediaItem(image:  imageView.image)
                    let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                    let mes5 = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: img2!)
                    self.handleImageForIndexPath(indexPath: NSIndexPath.init(row: self.messages.count, section: 0), image: textMsg, appliesMediaViewMaskAsOutgoing:true, date: date)
                    self.messages.append(mes5!)
                    
                }
                
            }
            else{
                let img2 = JSQPhotoMediaItem(image: imageView.image)
                img2?.appliesMediaViewMaskAsOutgoing = false
                let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                let mes5 = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: img2!)
                self.handleImageForIndexPath(indexPath: NSIndexPath.init(row: self.messages.count, section: 0), image: textMsg, appliesMediaViewMaskAsOutgoing:false, date: date)
                self.messages.append(mes5!)
                
            }
            Utility.showOrHideLoader(shouldShow: false)
            //            self.picker.dismiss(animated:true, completion: nil)
        }
        else if(isVideo)!{
            if(sender_Id == self.senderId){
                if (!self.shouldShowLocalVideoMessage){
                    let videoData = JSQVideoMediaItem(fileURL: URL(string: textMsg)!, isReadyToPlay: true)
                    videoData?.appliesMediaViewMaskAsOutgoing = true
                    let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                    let message = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: videoData)
                    self.messages.append(message!)
                }
            }
            else{
                let videoData = JSQVideoMediaItem(fileURL: URL(string: textMsg)!, isReadyToPlay: true)
                videoData?.appliesMediaViewMaskAsOutgoing = false
                let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                let message = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: videoData)
                self.messages.append(message!)
            }
        }
        else if (isAudio)!{
            
            if(sender_Id == self.senderId){
                if (!self.shouldShowLocalAudioMessage){
                    let audioData = JSQAudioMediaItem()
                    audioData.delegate = self
                    audioData.audioData = nil
                    let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                    let message = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: audioData)
                    self.handleAudioForIndexPath(indexPath: NSIndexPath.init(row: self.messages.count, section: 0), audioUrl: textMsg, appliesMediaViewMaskAsOutgoing: true, date: date)
                    self.messages.append(message!)
                }
            }
            else{
                let audioData = JSQAudioMediaItem()
                audioData.delegate = self
                audioData.audioData = nil
                audioData.appliesMediaViewMaskAsOutgoing = false
                let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                let message = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: audioData)
                self.handleAudioForIndexPath(indexPath: NSIndexPath.init(row: self.messages.count, section: 0), audioUrl: textMsg, appliesMediaViewMaskAsOutgoing: false, date: date)
                self.messages.append(message!)
            }
            
        }
        else{
            
            let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
            let message = JSQMessage.init(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, text: textMsg)
            self.messages.append(message!)
            
        }
        
        self.collectionView?.reloadData()
        self.scrollToBottom(animated: false)
    }
    
    func handleImageForIndexPath(indexPath: NSIndexPath, image: String, appliesMediaViewMaskAsOutgoing : Bool, date:Double) {
        DispatchQueue.global().async {
            
            SDWebImageDownloader.shared.downloadImage(with: NSURL.init(string: image) as URL?, options: [], progress: nil) { (image, data, error, success) in
                if error == nil {
                    DispatchQueue.main.async {
                        let img2 = JSQPhotoMediaItem(image: image)
                        img2?.appliesMediaViewMaskAsOutgoing = appliesMediaViewMaskAsOutgoing
                        let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                        let mes5 = JSQMessage(senderId: self.messages[indexPath.row].senderId, senderDisplayName: self.messages[indexPath.row].senderDisplayName, date: dateFromTimeStamp as Date?, media: img2!)
                        self.messages[indexPath.row] = mes5!
                        self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                    }
                }
            }
        }
    }
    
    func handleAudioForIndexPath(indexPath: NSIndexPath, audioUrl: String, appliesMediaViewMaskAsOutgoing: Bool, date: Double){
        
        DispatchQueue.global().async {
            let audioData = JSQAudioMediaItem()
            do {
                let data = try Data(contentsOf: URL(string: audioUrl)!)
                audioData.audioData = data
                audioData.delegate = self
                audioData.appliesMediaViewMaskAsOutgoing = appliesMediaViewMaskAsOutgoing
                
            } catch {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                let message = JSQMessage(senderId: self.messages[indexPath.row].senderId, senderDisplayName: self.messages[indexPath.row].senderDisplayName, date: dateFromTimeStamp as Date?, media: audioData)
                self.messages[indexPath.row] = message!
                self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
            }
            
        }
        
    }
    
    func handleVideoForIndexPath(indexPath: NSIndexPath, videoUrl: String, appliesMediaViewMaskAsOutgoing: Bool, date: Double){
        
        DispatchQueue.global().async {
            let videoData = JSQVideoMediaItem(fileURL: self.videoURL!, isReadyToPlay: true)
            do {
                // videoData.fileURL = URL(string: videoUrl)
                videoData!.appliesMediaViewMaskAsOutgoing = appliesMediaViewMaskAsOutgoing
                
            } catch {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                let message = JSQMessage(senderId: self.messages[indexPath.row].senderId, senderDisplayName: self.messages[indexPath.row].senderDisplayName, date: dateFromTimeStamp as Date?, media: videoData)
                self.messages[indexPath.row] = message!
                self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
            }
            
        }
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        //        isRecording = !isRecording
        //        if (isRecording){
        //            self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "rec-1"), for: .normal)
        //            self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "rec-1"), for: .selected)
        //            self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "rec-1"), for: .highlighted)
        //        }
        //        else{
        //            self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "microphone"), for: .normal)
        //            self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "microphone"), for: .selected)
        //            self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "microphone"), for: .highlighted)
        //        }
        //        manageRecorder()
    }
    
    @objc func recordButtonPressed(gesture: UILongPressGestureRecognizer){
        
        let state = gesture.state
        if (state == .began){
            
            self.isRecordingCancel = false
            recordingSession = AVAudioSession.sharedInstance()
            
            do {
                try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .mixWithOthers)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.inputToolbar.contentView.textView.isUserInteractionEnabled = false
                            self.inputToolbar.contentView.textView.text = "     00:01 Swipe to cancel > > >"
                            self.runTimer()
                            self.recordingState = .startRecording
                            self.manageRecorder()
                        } else {
                            
                            Loaf("Could not record audio.", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                                
                            }
                        }
                    }
                }
            } catch {
                Loaf("Could not record audio.", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                    
                }
            }
            
        }
            
        else if (state == .ended){
            let button = gesture.view as! UIButton
            
            let location = gesture.location(in: button)
            isRecordingCancel = location.x > 150 ? true : false
            timer.invalidate()
            seconds = 1
            recordingState = isRecordingCancel ? .cancelRecording : .finishRecording
            manageRecorder()
            self.inputToolbar.contentView.textView.text = ""
            self.inputToolbar.contentView.textView.isUserInteractionEnabled = true
            // self.inputToolbar.contentView.textView.isEditable = true
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        seconds += 1
        self.inputToolbar.contentView.textView.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"     %02i:%02i Swipe to cancel > > >",minutes, seconds)
    }
    
    func manageRecorder(){
        
        if (recordingState == .startRecording){
            AudioRecorderSingleton.sharedManager.startRecording()
        }
        else if (recordingState == .cancelRecording){
            AudioRecorderSingleton.sharedManager.cancelRecording()
        }
        else if (recordingState == .finishRecording){
            AudioRecorderSingleton.sharedManager.finishRecording(success: true, completion: { (data) in
                DispatchQueue.main.async {
                    if let audioDta = data{
                        
                        let timeStemp = Int(Date().timeIntervalSince1970)
                        let mediaRef = self.storageRef?.child("/Media")
                        let iosRef = mediaRef?.child("/iOS").child("/Audio")
                        let audioRef = iosRef?.child("/ChatAudio\(timeStemp).m4a")
                        
                        let metadata = StorageMetadata()
                        metadata.contentType = "audio/m4a"
                        
                        var uploadingIndexPath : NSIndexPath?
                        
                        let uploadTask = audioRef?.putData(audioDta, metadata: metadata, completion: { (metaData, error) in
                            if(error != nil){
                                Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                                    
                                }
                            }else{
                                
                                audioRef?.downloadURL(completion: { (url, error) in
                                    if let audioUrl = url{
                                        //  self.messages.remove(at: uploadingIndexPath!.row)
                                        //  self.userImages.remove(at: uploadingIndexPath!.row)
                                        self.shouldShowLocalAudioMessage = true
                                        self.sendMsgToFireBase(sender: self.senderId, displayName: self.senderDisplayName, text: audioUrl.absoluteString, type: 3)
                                    }
                                })
                                
                                
                            }
                        })
                        uploadTask?.resume()
                        
                        var i = 0
                        uploadTask?.observe(.progress, handler: { (snapshot) in
                            if(i == 0){
                                
                                self.shouldShowLocalAudioMessage = true
                                let audioMessage = JSQAudioMediaItem(data: audioDta)
                                let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), media: audioMessage)
                                uploadingIndexPath = NSIndexPath.init(row: self.messages.count, section: 0)
                                self.messages.append(message!)
                                self.collectionView?.reloadData()
                                self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                                self.finishSendingMessage()
                                
                            }
                            i += 1
                            
                        })
                        
                        uploadTask?.observe(.success, handler: { (snapshot) in
                            
                        })
                    }
                }
                
            })
            
        }
    }
    
    //MARK:- Collection View Delegates
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        self.view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.row]
        if message.isMediaMessage{
            weak var mediaItem: JSQMessageMediaData? = message.media
            let photoItem = mediaItem as? JSQPhotoMediaItem
            if let image = photoItem?.image{
                let viewController = DTPhotoViewerController(referencedView: cell.messageBubbleImageView, image: image)
                viewController.delegate = self
                self.present(viewController, animated: true, completion: nil)
            }
            else if let videoItem = mediaItem as? JSQVideoMediaItem{
                
                let playerVC = MobilePlayerViewController()
                playerVC.setConfig(contentURL: videoItem.fileURL)
                playerVC.shouldAutoplay = true
                playerVC.activityItems = [videoItem.fileURL!]
                self.present(playerVC, animated: true, completion: nil)
                
                self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
            }
            else{
                self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        let data = self.messages[indexPath.row]
        return data
        
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        return 30
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.tag = indexPath.row
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showDeleteMessagePopup(_:)))
        longPressGesture.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPressGesture)
        let data = self.messages[indexPath.row]
        
        DispatchQueue.main.async {
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
            cell.avatarImageView.clipsToBounds = true
        }
        
        cell.avatarContainerView.layer.cornerRadius = cell.avatarContainerView.frame.height / 2
        
        if (data.senderId == "\(Utility.getLoginUserId())"){
            cell.avatarImageView.sd_setImage(with: URL(string: Utility.getLoginUserImage()), placeholderImage: UIImage(named: "img_placeholder"))
        }
        else{
            if (self.groupModel.groupUsers.filter{$0.userId == Int(data.senderId)}.first != nil){
                let model = self.groupModel.groupUsers.filter{$0.userId == Int(data.senderId)}.first!
                cell.avatarImageView.sd_setImage(with: URL(string: model.userImage), placeholderImage: UIImage(named: "img_placeholder"))
            }
            else{
                cell.avatarImageView.image = UIImage(named: "img_placeholder")
            }
        }
       
        cell.cellBottomLabel.font = Theme.getLatoRegularFontOfSize(size: 11)
        cell.cellTopLabel.font = Theme.getLatoRegularFontOfSize(size: 12)
        
        if cell.textView != nil{
       //     cell.textView.font = Theme.getLatoRegularFontOfSize(size: 18)
      //      cell.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
            
            if data.senderId == self.senderId{
                cell.textView.textColor = UIColor.white
            }
            else{
                cell.textView.textColor = UIColor.white
            }
        }
        
        if data.senderId == self.senderId{
            cell.cellTopLabel.text = "You"
            cell.cellTopLabel.textAlignment = .right
            cell.cellBottomLabel.text = "\(Utility.getNotificationTime(date: data.date))"
        }
        else{
            cell.cellTopLabel.text = data.senderDisplayName
            cell.cellTopLabel.textAlignment = .left
            cell.cellBottomLabel.text = "\(Utility.getNotificationTime(date: data.date))"
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (indexPath.row == 0){
            
            if (!isAllMessagesLoad && self.messages.count >= 100){
                isAllMessagesLoad = true
                self.messageAdded(isFirstTime: false)
            }
        }
    }
    
    func audioMediaItem(_ audioMediaItem: JSQAudioMediaItem, didChangeAudioCategory category: String, options: AVAudioSession.CategoryOptions = [], error: Error?) {
        
    }
    
    @objc func showDeleteMessagePopup(_ sender: UILongPressGestureRecognizer){
        if ((messages[sender.view!.tag].senderId == self.senderId) && (messageKeys.count == messages.count)){
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteMessage = UIAlertAction(title: "Remove Message", style: .default) { (action) in
                DispatchQueue.main.async {
                    let messageKey = self.messageKeys[sender.view!.tag]
                    self.chatRef.child(messageKey).removeValue()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertVC.addAction(deleteMessage)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    @objc func sendButtonTapped(){
        
        if (self.inputToolbar.contentView.textView.text != ""){
            didPressSend(sendButton, withMessageText: self.inputToolbar.contentView.textView.text!, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date())
        }
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        sendMsgToFireBase(sender: senderId, displayName: senderDisplayName, text: text)
        finishSendingMessage()
        self.collectionView?.reloadData()
        self.scrollToBottom(animated: true)
    }
    
    func sendMsgToFireBase(sender: String!, displayName : String!, text: String!, type: Int?=1){
        
        chatRef.childByAutoId().updateChildValues(["senderName":displayName!,
                                                   "senderId":sender!,
                                                   "message":text!,
                                                   "type":type!,
                                                   "isRead": !shouldSendNotification,
                                                   "timestamp" : ServerValue.timestamp()])
        if (type! > 1){
            groupMediaRef.childByAutoId().updateChildValues(["mediaUrl": text!,
                                                             "mediaType": type!,
                                                             "mediaTimestamp": ServerValue.timestamp()])
        }
        
        
        sendPushNotification()
        
    }
    
    func sendPushNotification(){
        let params = ["user_id": "",
                      "alert": "\(self.groupModel.groupName): \(Utility.getLoginUserFullName()) sent a message",
            "name": Utility.getLoginUserFullName(),
            "data": "",
            "tag": 11,
            "chat_room_id": self.chatId] as [String: Any]
        API.sharedInstance.executeAPI(type: .sendPushNotification, method: .post, params: params) { (status, result, message) in
            
        }
    }
    
    func saveImageToFireBaseStorage(image: UIImage){
        
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Images")
        let picRef = iosRef?.child("/GroupChatImage\(timeStemp).jgp")
        
        //        let imageData2 = UIImagePNGRepresentation(image)
        if let imageData2 = image.jpegData(compressionQuality: 0.3) {
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            // Upload data and metadata
            //        picRef?.put(imageData2!, metadata: metadata)
            
            
            var uploadingIndexPath : NSIndexPath?
            
            let uploadTask = picRef?.putData(imageData2, metadata: metadata, completion: { (metaData, error) in
                if(error != nil){
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    picRef?.downloadURL(completion: { (url, error) in
                        if let imageURL = url{
                            // self.messages.remove(at: uploadingIndexPath!.row)
                            self.shouldShowLocalImageMessage = true
                            self.sendMsgToFireBase(sender: self.senderId, displayName: self.senderDisplayName, text: imageURL.absoluteString, type: 2)
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
                if(i == 0){
                    
                    let activity = UIActivityIndicatorView(style: .gray)
                    //                let maskView = UIView()
                    //                maskView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                    //                activity.mask = maskView
                    activity.startAnimating()
                    
                    let imageView = UIImageView()
                    activity.frame = imageView.frame
                    imageView.image = image
                    imageView.addSubview(activity)
                    
                    let img2 = JSQPhotoMediaItem(image:  imageView.image)
                    let mes5 = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), media: img2!)
                    uploadingIndexPath = NSIndexPath.init(row: self.messages.count, section: 0)
                    self.shouldShowLocalImageMessage = true
                    self.messages.append(mes5!)
                    self.collectionView?.reloadData()
                    self.finishSendingMessage()
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
        }
    }
    
    func saveVideoToFireBaseStorage(){
        
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Videos")
        let videoRef = iosRef?.child("/GroupChatVideo\(timeStemp).mov")
        
        if let videoData = try? Data(contentsOf: self.videoURL){
            
            var uploadingIndexPath : NSIndexPath?
            
            let uploadTask = videoRef?.putData(videoData, metadata: nil, completion: { (metaData, error) in
                if(error != nil){
                    Loaf(error!.localizedDescription, state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short) { (handler) in
                        
                    }
                }else{
                    
                    videoRef?.downloadURL(completion: { (url, error) in
                        if let imageURL = url{
                            // self.messages.remove(at: uploadingIndexPath!.row)
                            self.shouldShowLocalVideoMessage = true
                            self.sendMsgToFireBase(sender: self.senderId, displayName: self.senderDisplayName, text: imageURL.absoluteString, type: 4)
                        }
                    })
                    
                    
                }
            })
            uploadTask?.resume()
            
            var i = 0
            uploadTask?.observe(.progress, handler: { (snapshot) in
                if(i == 0){
                    
                    let img2 = JSQVideoMediaItem(fileURL: self.videoURL!, isReadyToPlay: true)
                    let mes5 = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), media: img2)
                    uploadingIndexPath = NSIndexPath.init(row: self.messages.count, section: 0)
                    self.shouldShowLocalVideoMessage = true
                    self.messages.append(mes5!)
                    self.collectionView?.reloadData()
                    self.finishSendingMessage()
                    
                }
                i += 1
                
            })
            
            uploadTask?.observe(.success, handler: { (snapshot) in
                
            })
            
        }
        
    }
    
    @objc func showImagePicker(){
        
        let alertVC = UIAlertController(title: "Select Action", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
}

extension GroupChatViewController: DTPhotoViewerControllerDelegate{
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, didEndPanGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        self.collectionView.reloadData()
    }
}

extension GroupChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.saveImageToFireBaseStorage(image: image)
        }
        if let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            self.videoURL = video
            self.saveVideoToFireBaseStorage()
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
