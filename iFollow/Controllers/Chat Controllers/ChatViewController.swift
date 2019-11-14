//
//  ChatViewController.swift
//  iFollow
//
//  Created by Shahzeb siddiqui on 13/11/2019.
//  Copyright © 2019 Shahzeb siddiqui. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, JSQMessageMediaData {
    
    var isPrivateChat = false
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var messages = [JSQMessage]()
    var userImages = [String]()
    var sendButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: isPrivateChat ? Theme.privateChatIncomingMessage : Theme.profileLabelsYellowColor)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: isPrivateChat ? Theme.privateChatOutgoingMessage : Theme.privateChatBoxSearchBarColor)
        
        if (isPrivateChat){
            self.collectionView.backgroundColor = Theme.privateChatBackgroundColor
            self.inputToolbar.contentView.textView.textColor = .white
        }
        self.setup()
        self.messageAdded()
        self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "emojiIcon"), for: .normal)
        self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "emojiIcon"), for: .selected)
        self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "emojiIcon"), for: .highlighted)
      //  self.inputToolbar.contentView.textView.layer.borderColor = UIColor.clear.cgColor
        self.inputToolbar.contentView.dropShadow(color: isPrivateChat ? Theme.privateChatBackgroundColor : .white)
       // self.inputToolbar.contentView.frame = CGRect(x: 30, y: 5, width: 100, height: 80)
        self.inputToolbar.contentView.textView.placeHolder = "Type a message..."
        self.inputToolbar.contentView.textView.font = Theme.getLatoRegularFontOfSize(size: 15)
        self.inputToolbar.contentView.textView.layer.borderColor = UIColor.clear.cgColor
        self.inputToolbar.contentView.textView.backgroundColor = .clear
        //self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send-1"), for: .normal)
        //self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send-1"), for: .selected)
        //self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send-1"), for: .highlighted)
        
        let rightContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
        let audioButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
        audioButton.setImage(UIImage(named: "microphone"), for: .normal)
        sendButton = UIButton(frame: CGRect(x: 30, y: 0, width: 20, height: 30))
        sendButton.setImage(UIImage(named: "send-1"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        rightContainerView.backgroundColor = .clear
        rightContainerView.addSubview(audioButton)
        rightContainerView.addSubview(sendButton)
        self.inputToolbar.contentView.rightBarButtonContainerView.addSubview(rightContainerView)
        self.inputToolbar.contentView.rightContentPadding = 30
        
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .selected)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .highlighted)
        
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
        self.senderId = "1"
        self.senderDisplayName = "Bella Nova"
    }
    
    func messageAdded(){
        
//        chatRef?.observe(.childAdded, with: { (snapshot) in
//
//            let type = snapshot.childSnapshot(forPath: "type").value as! Int
//            let sender = snapshot.childSnapshot(forPath: "senderId").value as! String
//            let message = snapshot.childSnapshot(forPath: "message").value as! String
//            let user_name = snapshot.childSnapshot(forPath: "senderName").value as! String
//            let userImage = snapshot.childSnapshot(forPath: "userImage").value as! String
//            let date = snapshot.childSnapshot(forPath: "timestemp").value as! Double
//
//            if(type == 1){
//                self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message,date: date)
//            }else{
//                self.addDemoMessages(sender_Id: sender, senderName: user_name, textMsg: message, isImage: true,date: date)
//
//            }
//            self.userImages.append(userImage)
//        })
        
        self.addDemoMessages(sender_Id: senderId, senderName: senderDisplayName, textMsg: "Hello Friend how are you?", date: Date().timeIntervalSince1970)
        self.userImages.append("chatUserIcon")
        self.addDemoMessages(sender_Id: "2", senderName: "Emma", textMsg: "I am fine what about you?", date: Date().timeIntervalSince1970)
        self.userImages.append("chatUserIcon")
        self.addDemoMessages(sender_Id: senderId, senderName: senderDisplayName, textMsg: "What's going on?", date: Date().timeIntervalSince1970)
        self.userImages.append("chatUserIcon")
        self.addDemoMessages(sender_Id: "2", senderName: "Emma", textMsg: "Nothing. Just thinking about work..", date: Date().timeIntervalSince1970)
        self.userImages.append("chatUserIcon")
        
        
    }
    
    func addDemoMessages(sender_Id : String, senderName : String, textMsg : String, isImage :Bool?=false, date:Double) {
        
        if(isImage)!{
            
            let activity = UIActivityIndicatorView(style: .gray)
            activity.startAnimating()
            
            let imageView = UIImageView()
            activity.frame = imageView.frame
            imageView.image = nil
            imageView.addSubview(activity)
            
            if(sender_Id == self.senderId){
                
                let img2 = JSQPhotoMediaItem(image:  imageView.image)
                let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                let mes5 = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: img2!)
                self.handleImageForIndexPath(indexPath: NSIndexPath.init(row: self.messages.count, section: 0), image: textMsg, appliesMediaViewMaskAsOutgoing:true, date: date)
                self.messages.append(mes5!)
            }
            else{
                let img2 = JSQPhotoMediaItem(image: imageView.image)
                img2?.appliesMediaViewMaskAsOutgoing = false
                let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
                let mes5 = JSQMessage(senderId: sender_Id, senderDisplayName: senderName, date: dateFromTimeStamp as Date?, media: img2!)
                self.handleImageForIndexPath(indexPath: NSIndexPath.init(row: self.messages.count, section: 0), image: textMsg, appliesMediaViewMaskAsOutgoing:false, date: date)
                self.messages.append(mes5!)
                
            }
           // SVProgressHUD.dismiss()
            //            self.picker.dismiss(animated:true, completion: nil)
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
//        DispatchQueue.global().async {
//            
//            SDWebImageDownloader.shared().downloadImage(with: NSURL.init(string: image) as URL!, options: [], progress: nil) { (image, data, error, success) in
//                if error == nil {
//                    DispatchQueue.main.async {
//                        let img2 = JSQPhotoMediaItem(image: image)
//                        img2?.appliesMediaViewMaskAsOutgoing = appliesMediaViewMaskAsOutgoing
//                        let dateFromTimeStamp : NSDate = NSDate(timeIntervalSince1970: Double(date/1000))
//                        let mes5 = JSQMessage(senderId: self.messages[indexPath.row].senderId, senderDisplayName: self.messages[indexPath.row].senderDisplayName, date: dateFromTimeStamp as Date!, media: img2!)
//                        self.messages[indexPath.row] = mes5!
//                        self.collectionView.reloadData()
//                    }
//                }
//            }
//        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
//        let alertController = UIAlertController(title: "Photo", message: "Choose action", preferredStyle: .actionSheet)
//        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
//
//            self.picker.allowsEditing = true
//            self.picker.sourceType = .camera
//            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
//            self.present(self.picker, animated: true, completion: nil)
//
//        }
//        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (UIAlertAction) in
//
//            self.picker.allowsEditing = true
//            self.picker.sourceType = .photoLibrary
//            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
//            self.present(self.picker, animated: true, completion: nil)
//
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
//
//        alertController.addAction(cameraAction)
//        alertController.addAction(galleryAction)
//        alertController.addAction(cancelAction)
//
//        self.present(alertController, animated: true, completion: nil)
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
        
//        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
//        let message = self.messages[indexPath.row]
//        if message.isMediaMessage{
//            selectedPicIndexPath = indexPath
//            weak var mediaItem: JSQMessageMediaData? = message.media
//            let photoItem = mediaItem as? JSQPhotoMediaItem
//
//            if let viewController = DTPhotoViewerController(referencedView: cell.messageBubbleImageView, image: photoItem?.image){
//                viewController.delegate = self
//                self.present(viewController, animated: true, completion: nil)
//            }
//        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        let data = self.messages[indexPath.row]
        return data
        
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        
    }
    
    //    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    //
    //        let data = self.messages[indexPath.row]
    //        let senderName = data.senderDisplayName!
    //        let senderattributedName = NSAttributedString(string: senderName)
    //        if data.senderId == self.senderId{
    //            return nil
    //        }
    //        else{
    //            return senderattributedName
    //        }
    //
    //    }
    
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
            if self.messages.count == self.userImages.count{
               // cell.avatarImageView.frame.size = CGSize(width: 40, height: 40)
              //  cell.cellBottomLabel.frame.origin.y = cell.cellBottomLabel.frame.origin.y + 10
                cell.avatarImageView.image = UIImage(named: self.userImages[indexPath.row])
               // cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
                cell.avatarImageView.clipsToBounds = false
                cell.messageBubbleContainerView.layer.cornerRadius = 3.0
                cell.cellBottomLabel.font = Theme.getLatoRegularFontOfSize(size: 11)
                
                if cell.textView != nil{
                    cell.textView.font = Theme.getLatoRegularFontOfSize(size: 15)
                    cell.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
                    
                    if data.senderId == self.senderId{
                        cell.avatarImageView.isHidden = true
                        cell.textView.textColor = UIColor.white
                     //   cell.messageBubbleContainerView.frame.origin.x = cell.messageBubbleContainerView.frame.origin.x + 20
                    }
                    else{
                        cell.avatarImageView.isHidden = false
                        cell.textView.textColor = UIColor.white
                     //    cell.messageBubbleContainerView.frame.origin.x = cell.messageBubbleContainerView.frame.origin.x + 10
                    }
                }
                if data.senderId == self.senderId{
                    cell.cellBottomLabel.text = "09:40 pm"
                }
                else{
                    cell.cellBottomLabel.text = data.senderDisplayName
                }
                
              //  cell.messageBubbleContainerView.frame.size = CGSize(width: cell.messageBubbleContainerView.frame.size.width, height: cell.textView.frame.height)
            }
        }
        
        return cell
    }
    
    @objc func sendButtonTapped(){
        
        if (self.inputToolbar.contentView.textView.text != ""){
            didPressSend(sendButton, withMessageText: self.inputToolbar.contentView.textView.text!, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date())
        }
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        self.addDemoMessages(sender_Id: self.senderId, senderName: self.senderDisplayName, textMsg: text, date: Date().timeIntervalSince1970)
        self.userImages.append("chatUserIcon")
        finishSendingMessage()
        self.collectionView?.reloadData()
        self.scrollToBottom(animated: true)
    }
    
}
