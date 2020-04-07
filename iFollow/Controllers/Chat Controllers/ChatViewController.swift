//
//  ChatViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 13/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
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

enum RecordingEnum {
    case startRecording
    case finishRecording
    case cancelRecording
}

class ChatViewController: JSQMessagesViewController, JSQMessageMediaData, JSQAudioMediaItemDelegate {
    
    var isPrivateChat = false
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var messages = [JSQMessage]()
    var sendButton = UIButton()
    var recordButton = UIButton()
    var chatRef = rootRef
    var storageRef : StorageReference?
    var recordingSession: AVAudioSession!
    var chatId = ""
    var userImage = ""
    var userName = ""
    var otherUserId = ""
    var timer = Timer()
    var seconds = 1
    var recordingState: RecordingEnum!
    var shouldShowLocalImageMessage = false
    var shouldShowLocalAudioMessage = false
    var isRecordingCancel = false
    var shouldSendNotification = false
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: isPrivateChat ? Theme.privateChatIncomingMessage : Theme.profileLabelsYellowColor)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: isPrivateChat ? Theme.privateChatOutgoingMessage : Theme.privateChatBoxSearchBarColor)
        
        if (isPrivateChat){
            chatRef = chatRef.child("PrivateChats").child(chatId)
            self.collectionView.backgroundColor = Theme.privateChatBackgroundColor
            self.inputToolbar.contentView.backgroundColor = Theme.privateChatBackgroundColor
            self.inputToolbar.contentView.textView.textColor = .white
            self.inputToolbar.contentView.textView.backgroundColor = Theme.privateChatBackgroundColor
            
        }
        else{
            chatRef = chatRef.child("NormalChats").child(chatId)
            self.inputToolbar.contentView.backgroundColor = .white
            self.inputToolbar.contentView.textView.textColor = .black
            self.inputToolbar.contentView.textView.backgroundColor = .clear
        }
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        self.setup()
        self.messageAdded()
        self.inputToolbar.contentView.textView.placeHolder = "Type a message..."
        self.inputToolbar.contentView.textView.layer.borderColor = UIColor.clear.cgColor
        
        
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
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
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
    
    func messageAdded(){
        
//        let userRef = rootRef.child("users").child(otherUserId)
//        userRef.observe(.value) { (snapshot) in
//            if (snapshot.hasChild("isOnChat")){
//                let isOnChat = snapshot.childSnapshot(forPath: "isOnChat").value as! Bool
//                self.shouldSendNotification = !isOnChat
//            }
//
//        }
        
        chatRef.observe(.childAdded, with: { (snapshot) in
            
            if (self.isPrivateChat){
                let type = snapshot.childSnapshot(forPath: "type").value as! Int
                let sender = snapshot.childSnapshot(forPath: "senderId").value as! String
                let message = snapshot.childSnapshot(forPath: "message").value as! String
                let user_name = snapshot.childSnapshot(forPath: "senderName").value as! String
                let date = snapshot.childSnapshot(forPath: "timestamp").value as! Double
                let isRead = snapshot.childSnapshot(forPath: "isRead").value as! Bool
                let expireTime = snapshot.childSnapshot(forPath: "expireTime").value as! Double
                
                let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
                
                if (Int64(expireTime) > currentTime){
                    if(type == 1){
                        self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date)
                    }else if (type == 2){
                        self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date)
                    }
                    else{
                        self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date)
                        
                    }
                }
                
            }
            else{
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
                else{
                    self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date)
                    
                }
            }
            
        })
        
    }
    
    func addDemoMessages(sender_Id : String, senderName : String, textMsg : String, isImage :Bool?=false, isAudio:Bool?=false, date:Double) {
        
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
                try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
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
        
        return 5
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = self.messages[indexPath.row]
        
        DispatchQueue.main.async {
            
            cell.avatarContainerView.layer.cornerRadius = cell.avatarContainerView.frame.height / 2
            cell.avatarImageView.sd_setImage(with: URL(string: data.senderId == self.senderId ? Utility.getLoginUserImage() : self.userImage), placeholderImage: UIImage(named: "img_placeholder"))
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
            cell.avatarImageView.clipsToBounds = true
            cell.cellBottomLabel.font = Theme.getLatoRegularFontOfSize(size: 11)
            
            if cell.textView != nil{
                cell.textView.font = Theme.getLatoRegularFontOfSize(size: 15)
                cell.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
                
                if data.senderId == self.senderId{
                    cell.textView.textColor = UIColor.white
                }
                else{
                    cell.textView.textColor = UIColor.white
                }
            }
            
            if data.senderId == self.senderId{
                cell.cellBottomLabel.text = "\(Utility.getNotificationTime(date: data.date))"
            }
            else{
                cell.cellBottomLabel.text = "\(Utility.getNotificationTime(date: data.date))"
            }
            
        }
        
        return cell
    }
    
    func audioMediaItem(_ audioMediaItem: JSQAudioMediaItem, didChangeAudioCategory category: String, options: AVAudioSession.CategoryOptions = [], error: Error?) {
        
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
        
        if (isPrivateChat){
            let messageTime = ServerValue.timestamp()
            let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
            let messageExpireTime = currentTime + 43200000//300000
            chatRef.childByAutoId().updateChildValues(["senderName":displayName!,
                                                       "senderId":sender!,
                                                       "message":text!,
                                                       "type":type!,
                                                       "isRead": false,
                                                       "timestamp": messageTime,
                                                       "expireTime": messageExpireTime])
        }
        else{
            chatRef.childByAutoId().updateChildValues(["senderName":displayName!,
                                                       "senderId":sender!,
                                                       "message":text!,
                                                       "type":type!,
                                                       "isRead": false,
                                                       "timestamp" : ServerValue.timestamp()])
        }
        
        sendPushNotification()
        
    }
    
    func sendPushNotification(){
//        if (shouldSendNotification){
//            let params = ["node_id": chatId,
//                          "receiver_id": otherUserId]
//            API.sharedInstance.executeAPI(type: .sendChatNotification, method: .post, params: params) { (status, result, message) in
//
//            }
//        }
    }
    
    func saveImageToFireBaseStorage(image: UIImage){
        
        let timeStemp = Int(Date().timeIntervalSince1970)
        let mediaRef = storageRef?.child("/Media")
        let iosRef = mediaRef?.child("/iOS").child("/Images")
        let picRef = iosRef?.child("/ChatImage\(timeStemp).jgp")
        
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

extension ChatViewController: DTPhotoViewerControllerDelegate{
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, didEndPanGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        self.collectionView.reloadData()
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.saveImageToFireBaseStorage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
