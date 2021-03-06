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
import AVFoundation
import AVKit
import Photos

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
    var otherUserId = 0
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
    var messagesModel = [MessagesModel]()
    var lastMessageKey = ""
    var isAllMessagesLoad = false
    var messageKeys = [String]()
//    var isLastMessageSeen = false
    var myTypingRef = rootRef
    var userTypingRef = rootRef
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.videoMaximumDuration = 60
        imagePicker.videoQuality = .typeHigh
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: isPrivateChat ? Theme.privateChatIncomingMessage : Theme.profileLabelsYellowColor)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: isPrivateChat ? Theme.privateChatOutgoingMessage : Theme.privateChatBoxSearchBarColor)
        
        if (isPrivateChat){
            chatRef = chatRef.child("PrivateChats").child(chatId)
        }
        else{
            chatRef = chatRef.child("NormalChats").child(chatId)
    
        }
        
        setupColors()
        myTypingRef = myTypingRef.child("Typing")
        userTypingRef = userTypingRef.child("Typing")
        self.showUserTypingIndicator()
        storageRef = Storage.storage().reference(forURL: FireBaseStorageURL)
        self.setup()
        self.messageAdded(isFirstTime: true)
        self.inputToolbar.contentView.textView.placeHolder = "Type a message..."
        self.inputToolbar.contentView.textView.layer.borderColor = UIColor.clear.cgColor
        self.inputToolbar.contentView.textView.autocorrectionType = .yes
        
        let rightContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 42))
        
        sendButton = UIButton(frame: CGRect(x: -3, y: -5, width: 40, height: 42  ))
        sendButton.setImage(UIImage(named: "send-2"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        rightContainerView.backgroundColor = .clear
        rightContainerView.addSubview(sendButton)
        self.inputToolbar.contentView.rightBarButtonContainerView.addSubview(rightContainerView)
        self.inputToolbar.contentView.rightContentPadding = 0
        
        let leftContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 42))
        
        recordButton = UIButton(frame: CGRect(x: 0, y: -5, width: 60, height: 42  ))
        recordButton.setImage(UIImage(named: "mic"), for: .normal)
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
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            self.myTypingRef.child(self.chatId).child(self.senderId).updateChildValues(["isTyping": false])
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isOnChat": false])
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isOnChat": true])
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil) { (notification) in
            let usersRef = rootRef.child("Users").child("\(Utility.getLoginUserId())")
            usersRef.updateChildValues(["isOnChat": false])
        }
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        myTypingRef.child(chatId).child(self.senderId).updateChildValues(["isTyping": false])
        
    }
    
    func setupColors(){
        if (isPrivateChat){
            self.collectionView.setPrivateChatColor()
            self.inputToolbar.contentView.setPrivateChatColor()
            self.inputToolbar.contentView.textView.textColor = .white
            self.inputToolbar.contentView.textView.setPrivateChatColor()
            
        }
        else{
            self.collectionView.setColor()
            self.inputToolbar.contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Theme.darkModeBlackColor : .white
            self.inputToolbar.contentView.textView.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
            self.inputToolbar.contentView.textView.backgroundColor = .clear
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
            let userRef = rootRef.child("Users").child("\(otherUserId)")
             userRef.observe(.value) { (snapshot) in
                 if (snapshot.hasChild("isOnChat")){
                     let isOnChat = snapshot.childSnapshot(forPath: "isOnChat").value as! Bool
                     self.shouldSendNotification = !isOnChat
                 }

             }
             
             chatRef.queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                 let chatNode = snapshot.key
                 self.lastMessageKey = snapshot.key
                 let userId = (snapshot.childSnapshot(forPath: "senderId").value as! String)
                 if (userId != "\(Utility.getLoginUserId())"){
                     let chatToUpdate = self.chatRef.child(chatNode)
                     chatToUpdate.updateChildValues(["isRead": true])
                 }
//                 else{
//                    let lastMessageRef = self.chatRef.child(chatNode)
//                    lastMessageRef.observe(.value) { (lastMessageSnapshot) in
//                        if (lastMessageSnapshot.childrenCount > 0){
//                            self.isLastMessageSeen = lastMessageSnapshot.childSnapshot(forPath: "isRead").value as! Bool
//                            self.collectionView.reloadData()
//                        }
//
//                    }
//                }
             }
             
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMessagesCounterAfterReadChat"), object: nil)
            
            chatRef.queryLimited(toLast: 100).observe(.childAdded, with: { (snapshot) in
                 
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
                         self.messageKeys.append(snapshot.key)
                         let model = MessagesModel()
                         model.senderId = sender
                         model.senderDisplayName = user_name
                         model.messageType = type
                         model.messageTimeStamp = date
                         model.message = message
                         model.postId = 0
                        self.messagesModel.append(model)
                         if(type == 1){
                             self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date, isFirstTime: isFirstTime)
                         }else if (type == 2){
                             self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date, isFirstTime: isFirstTime)
                         }
                         else if (type == 3){
                             self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date, isFirstTime: isFirstTime)
                             
                         }
                         else {
                             self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isVideo: true,date: date, isFirstTime: isFirstTime)
                         }
                     }
                     
                 }
                 else{
                     self.messageKeys.append(snapshot.key)
                     let type = snapshot.childSnapshot(forPath: "type").value as! Int
                     let sender = snapshot.childSnapshot(forPath: "senderId").value as! String
                     let message = snapshot.childSnapshot(forPath: "message").value as! String
                     let user_name = snapshot.childSnapshot(forPath: "senderName").value as! String
                     let date = snapshot.childSnapshot(forPath: "timestamp").value as! Double
                     let isRead = snapshot.childSnapshot(forPath: "isRead").value as! Bool
                     
                     var postId = 0
                     if (snapshot.hasChild("postId")){
                         postId = snapshot.childSnapshot(forPath: "postId").value as! Int
                     }
                     
                     let model = MessagesModel()
                     model.senderId = sender
                     model.senderDisplayName = user_name
                     model.messageType = type
                     model.messageTimeStamp = date
                     model.message = message
                     model.postId = postId
                     self.messagesModel.append(model)
                     
                     if(type == 1){
                         self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date, isFirstTime: isFirstTime)
                     }else if (type == 2){
                         self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date, isFirstTime: isFirstTime)
                     }
                     else if (type == 3){
                         self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date, isFirstTime: isFirstTime)
                         
                     }
                     else{
                         self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isVideo: true,date: date, isFirstTime: isFirstTime)
                     }
                 }
                 
             })
        }
        else{
            
            chatRef.queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                let chatNode = snapshot.key
                let userId = (snapshot.childSnapshot(forPath: "senderId").value as! String)
                if (userId != "\(Utility.getLoginUserId())"){
                    let chatToUpdate = self.chatRef.child(chatNode)
                    chatToUpdate.updateChildValues(["isRead": true])
                }
//                else{
//                    let lastMessageRef = self.chatRef.child(chatNode)
//                    lastMessageRef.observe(.value) { (lastMessageSnapshot) in
//                        if (lastMessageSnapshot.childrenCount > 0){
//                            self.isLastMessageSeen = lastMessageSnapshot.childSnapshot(forPath: "isRead").value as! Bool
//                            self.collectionView.reloadData()
//                        }
//
//                    }
//                }
            }
            
            Utility.showOrHideLoader(shouldShow: true)
            chatRef.removeAllObservers()
            self.messages.removeAll()
            self.messageKeys.removeAll()
            
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
                        self.messageKeys.append(snapshot.key)
                        
                        let model = MessagesModel()
                        model.senderId = sender
                        model.senderDisplayName = user_name
                        model.messageType = type
                        model.messageTimeStamp = date
                        model.message = message
                        model.postId = 0
                        self.messagesModel.append(model)
                        
                        if(type == 1){
                            self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date, isFirstTime: isFirstTime)
                        }else if (type == 2){
                            self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date, isFirstTime: isFirstTime)
                        }
                        else if (type == 3){
                            self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date, isFirstTime: isFirstTime)
                            
                        }
                        else {
                            self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isVideo: true,date: date, isFirstTime: isFirstTime)
                        }
                    }
                    
                }
                else{
                    self.messageKeys.append(snapshot.key)
                    let type = snapshot.childSnapshot(forPath: "type").value as! Int
                    let sender = snapshot.childSnapshot(forPath: "senderId").value as! String
                    let message = snapshot.childSnapshot(forPath: "message").value as! String
                    let user_name = snapshot.childSnapshot(forPath: "senderName").value as! String
                    let date = snapshot.childSnapshot(forPath: "timestamp").value as! Double
                    let isRead = snapshot.childSnapshot(forPath: "isRead").value as! Bool
                    
                    var postId = 0
                    if (snapshot.hasChild("postId")){
                        postId = snapshot.childSnapshot(forPath: "postId").value as! Int
                    }
                    
                    let model = MessagesModel()
                    model.senderId = sender
                    model.senderDisplayName = user_name
                    model.messageType = type
                    model.messageTimeStamp = date
                    model.message = message
                    model.postId = postId
                    self.messagesModel.append(model)
                    
                    if(type == 1){
                        self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date, isFirstTime: isFirstTime)
                    }else if (type == 2){
                        self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date, isFirstTime: isFirstTime)
                    }
                    else if (type == 3){
                        self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isAudio: true,date: date, isFirstTime: isFirstTime)
                        
                    }
                    else{
                        self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isVideo: true,date: date, isFirstTime: isFirstTime)
                    }
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
                if ((self.messagesModel.count - 1) >= indexOfDeleteMessageKey){
                    self.messagesModel.remove(at: indexOfDeleteMessageKey)
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    func showUserTypingIndicator(){
        userTypingRef.child(chatId).child("\(otherUserId)").observe(.value) { (snapshot) in
            if (snapshot.hasChild("isTyping")){
                let isUserTyping = snapshot.childSnapshot(forPath: "isTyping").value as! Bool
                self.showTypingIndicator = isUserTyping
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func addDemoMessages(sender_Id : String, senderName : String, textMsg : String, isImage :Bool?=false, isAudio:Bool?=false, isVideo:Bool?=false, date:Double, isFirstTime: Bool) {
        
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
                    audioData.mediaView()?.tintColor = isPrivateChat ? Theme.privateChatOutgoingMessage : Theme.privateChatBoxSearchBarColor
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
                audioData.mediaView()?.tintColor = isPrivateChat ? Theme.privateChatIncomingMessage : Theme.profileLabelsYellowColor
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
            if (appliesMediaViewMaskAsOutgoing){
                audioData.mediaView()?.tintColor = self.isPrivateChat ? Theme.privateChatOutgoingMessage : Theme.privateChatBoxSearchBarColor
            }
            else{
                audioData.mediaView()?.tintColor = self.isPrivateChat ? Theme.privateChatIncomingMessage : Theme.profileLabelsYellowColor
            }
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
                                
                                let model = MessagesModel()
                                model.senderId = self.senderId
                                model.senderDisplayName = self.senderDisplayName
                                model.messageType = 3
                                model.messageTimeStamp = 0
                                model.message = ""
                                model.postId = 0
                                self.messagesModel.append(model)
                                
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupColors()
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
            
            if (isPrivateChat){
                weak var mediaItem: JSQMessageMediaData? = message.media
                let photoItem = mediaItem as? JSQPhotoMediaItem
                if let image = photoItem?.image{
                    let viewController = DTPhotoViewerController(referencedView: cell.messageBubbleImageView, image: image)
                    viewController.delegate = self
                    self.present(viewController, animated: true, completion: nil)
                    self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                    
                }
                else if let videoItem = mediaItem as? JSQVideoMediaItem{
                    let player = AVPlayer(url: videoItem.fileURL)
                    
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                    self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                }
                else{
                    self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                }
            }
            else{
                if (self.messagesModel[indexPath.row].postId != 0){
                    let vc = Utility.getPostDetailViewController()
                    vc.postId = self.messagesModel[indexPath.row].postId
                    self.present(vc, animated: true, completion: nil)
                    self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                    self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                }
                else{
                    weak var mediaItem: JSQMessageMediaData? = message.media
                    let photoItem = mediaItem as? JSQPhotoMediaItem
                    if let image = photoItem?.image{
                        let viewController = DTPhotoViewerController(referencedView: cell.messageBubbleImageView, image: image)
                        viewController.delegate = self
                        self.present(viewController, animated: true, completion: nil)
                        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                        self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                    }
                    else if let videoItem = mediaItem as? JSQVideoMediaItem{
                        let playerVC = MobilePlayerViewController()
                        playerVC.setConfig(contentURL: videoItem.fileURL)
                        playerVC.shouldAutoplay = true
                        playerVC.activityItems = [videoItem.fileURL!]
                        self.present(playerVC, animated: true, completion: nil)
                        
                        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                        self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                    }
                    else{
                        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                        self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                     }
                }
            }
            
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        if (self.messages.count > 0){
            let data = self.messages[indexPath.row]
            return data
        }
        return nil
        
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if (indexPath.row == messages.count - 1){
//            if (messages[indexPath.row].senderId == self.senderId && isLastMessageSeen){
//                return 20
//            }
//            else{
//                return 5
//            }
        }
        return 5
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.tag = indexPath.row
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showDeleteMessagePopup(_:)))
        longPressGesture.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPressGesture)
        let data = self.messages[indexPath.row]
        
        DispatchQueue.main.async {
            
            cell.avatarContainerView.layer.cornerRadius = cell.avatarContainerView.frame.height / 2
            cell.avatarImageView.sd_setImage(with: URL(string: data.senderId == self.senderId ? Utility.getLoginUserImage() : self.userImage), placeholderImage: UIImage(named: "img_placeholder"))
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
            cell.avatarImageView.clipsToBounds = true
            cell.cellBottomLabel.font = Theme.getLatoRegularFontOfSize(size: 11)
            cell.cellTopLabel.font = Theme.getLatoRegularFontOfSize(size: 11)
            cell.cellTopLabel.textAlignment = .right
            
            if cell.textView != nil{
             //   cell.textView.font = Theme.getLatoRegularFontOfSize(size: 18)
            //    cell.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
                
                if data.senderId == self.senderId{
                    cell.textView.textColor = UIColor.white
                }
                else{
                    cell.textView.textColor = UIColor.white
                }
            }
            
//            if data.senderId == self.senderId{
//                if (indexPath.row == self.messages.count - 1 && self.isLastMessageSeen){
//                    cell.cellTopLabel.text = "\(Utility.timeAgoSince(data.date))"
//                    cell.cellBottomLabel.text = "Seen"
//                }
//                else{
//                    cell.cellTopLabel.text = ""
//                    cell.cellBottomLabel.text = "\(Utility.timeAgoSince(data.date))"
//                }
//            }
//            else{
                cell.cellTopLabel.text = ""
                cell.cellBottomLabel.text = "\(Utility.timeAgoSince(data.date))"
//            }
            
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
    
    @objc func showDeleteMessagePopup(_ sender: UILongPressGestureRecognizer){
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteMessage = UIAlertAction(title: "Remove Message", style: .default) { (action) in
            DispatchQueue.main.async {
                let messageKey = self.messageKeys[sender.view!.tag]
                self.chatRef.child(messageKey).removeValue()
            }
        }
        let saveMedia = UIAlertAction(title: "Save Media", style: .default) { (action) in
            DispatchQueue.main.async {
                self.saveMediaToPhone(index: sender.view!.tag)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if ((messages[sender.view!.tag].senderId == self.senderId) && (messageKeys.count == messages.count)){
            
            alertVC.addAction(deleteMessage)
            if (messages[sender.view!.tag].isMediaMessage && messagesModel[sender.view!.tag].messageType != 1 && messagesModel[sender.view!.tag].messageType != 3){
                alertVC.addAction(saveMedia)
            }
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        else if ((messages[sender.view!.tag].senderId != self.senderId) && (messageKeys.count == messages.count) && (messagesModel[sender.view!.tag].messageType != 1) && (messagesModel[sender.view!.tag].messageType != 3)){
            
            alertVC.addAction(saveMedia)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
            
        }
        
    }
    
    func saveMediaToPhone(index: Int){
        let messageModel = self.messagesModel[index]
        if (messageModel.messageType == 2){
            //image
            DispatchQueue.global(qos: .background).async {
                if let imageData = try? Data(contentsOf: URL(string: messageModel.message)!){
                    if let image = UIImage(data: imageData){
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                      
                    }
                }
            }
            
        }
        else if (messageModel.messageType == 4){
            //video
            DispatchQueue.global(qos: .background).async {
                if let url = URL(string: messageModel.message),
                    let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/\(UUID().uuidString).mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func audioMediaItem(_ audioMediaItem: JSQAudioMediaItem, didChangeAudioCategory category: String, options: AVAudioSession.CategoryOptions = [], error: Error?) {
        
    }
    
    @objc func sendButtonTapped(){
        
        if (self.inputToolbar.contentView.textView.text != ""){
            didPressSend(sendButton, withMessageText: self.inputToolbar.contentView.textView.text!, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date())
        }
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        myTypingRef.child(chatId).child(self.senderId).updateChildValues(["isTyping": false])
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
                                                       "isRead": !shouldSendNotification,
                                                       "timestamp": messageTime,
                                                       "expireTime": messageExpireTime])
        }
        else{
            chatRef.childByAutoId().updateChildValues(["senderName":displayName!,
                                                       "senderId":sender!,
                                                       "message":text!,
                                                       "type":type!,
                                                       "isRead": !shouldSendNotification,
                                                       "timestamp" : ServerValue.timestamp()])
        }
        
        sendPushNotification()
        
    }
    
    func sendPushNotification(){
        if (shouldSendNotification){
            let params = ["user_id": self.otherUserId,
                          "alert": isPrivateChat ? "\(Utility.getLoginUserFullName()) sent you a private message" : "\(Utility.getLoginUserFullName()) sent you a message",
                          "name": Utility.getLoginUserFullName(),
                          "data": isPrivateChat ? "\(Utility.getLoginUserFullName()) sent you a private message" : "\(Utility.getLoginUserFullName()) sent you a message",
                          "tag": isPrivateChat ? 13 : 12,
            "chat_room_id": self.chatId] as [String: Any]
            API.sharedInstance.executeAPI(type: .sendPushNotification, method: .post, params: params) { (status, result, message) in

            }
        }
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
                    
                    let model = MessagesModel()
                    model.senderId = self.senderId
                    model.senderDisplayName = self.senderDisplayName
                    model.messageType = 2
                    model.messageTimeStamp = 0
                    model.message = ""
                    model.postId = 0
                    self.messagesModel.append(model)
                    
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
        let videoRef = iosRef?.child("/ChatVideo\(timeStemp).mov")
        
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
                    
                    let model = MessagesModel()
                    model.senderId = self.senderId
                    model.senderDisplayName = self.senderDisplayName
                    model.messageType = 4
                    model.messageTimeStamp = 0
                    model.message = ""
                    model.postId = 0
                    self.messagesModel.append(model)
                    
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
        
        myTypingRef.child(chatId).child(self.senderId).updateChildValues(["isTyping": false])
        let vc = Utility.getCameraViewController()
        vc.isForPost = true
        vc.delegate = self
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.isNavigationBarHidden = true
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true, completion: nil)
//        let alertVC = UIAlertController(title: "Select Action", message: "", preferredStyle: .actionSheet)
//        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
//            self.imagePicker.sourceType = .camera
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
//        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
//            self.imagePicker.sourceType = .photoLibrary
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertVC.addAction(cameraAction)
//        alertVC.addAction(galleryAction)
//        alertVC.addAction(cancelAction)
//        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        myTypingRef.child(chatId).child(self.senderId).updateChildValues(["isTyping": true])
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        myTypingRef.child(chatId).child(self.senderId).updateChildValues(["isTyping": false])
    }
}

extension ChatViewController: DTPhotoViewerControllerDelegate{
    func photoViewerController(_ photoViewerController: DTPhotoViewerController, didEndPanGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
      //  self.collectionView.reloadData()
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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

extension ChatViewController: CameraViewControllerDelegate{
    func getStoryImage(image: UIImage, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        self.saveImageToFireBaseStorage(image: image)
    }
    
    func getStoryVideo(videoURL: URL, caption: String, isToSendMyStory: Bool, friendsArray: [RecentChatsModel], selectedTagsUserString: String, selectedTagUsersArray: [PostLikesUserModel]) {
        DispatchQueue.main.async {
            self.videoURL = videoURL
            self.saveVideoToFireBaseStorage()
        }
    }
}
