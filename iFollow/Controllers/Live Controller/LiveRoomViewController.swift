//
//  LiveRoomViewController.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit
import AgoraRtcKit
import Loaf
import Firebase

protocol LiveVCDataSource: NSObjectProtocol {
    func liveVCNeedAgoraKit() -> AgoraRtcEngineKit
    func liveVCNeedSettings() -> Settings
}

class LiveRoomViewController: UIViewController {
    
    @IBOutlet weak var broadcastersView: AGEVideoContainer!
    @IBOutlet weak var placeholderView: UIImageView!
    
    @IBOutlet weak var videoMuteButton: UIButton!
    @IBOutlet weak var audioMuteButton: UIButton!
    @IBOutlet weak var beautyEffectButton: UIButton!
    
    @IBOutlet var sessionButtons: [UIButton]!
    
    @IBOutlet weak var txtViewComment: UITextView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var eyeView: UIView!
    @IBOutlet weak var lblCount: UILabel!
    
    var liveRoomName = ""
    var commentRef = rootRef.child("LiveVideoComments")
    var viewsRef = rootRef.child("LiveVideoViews")
    var commentsArray = [LiveVideoCommentModel]()
    var totalViews = 0
    
    private let beautyOptions: AgoraBeautyOptions = {
        let options = AgoraBeautyOptions()
        options.lighteningContrastLevel = .normal
        options.lighteningLevel = 0.7
        options.smoothnessLevel = 0.5
        options.rednessLevel = 0.1
        return options
    }()
    
    private var agoraKit: AgoraRtcEngineKit {
        return dataSource!.liveVCNeedAgoraKit()
    }
    
    private var settings: Settings {
        return dataSource!.liveVCNeedSettings()
    }
    
    private var isMutedVideo = false {
        didSet {
            // mute local video
            agoraKit.muteLocalVideoStream(isMutedVideo)
            videoMuteButton.isSelected = isMutedVideo
        }
    }
    
    private var isMutedAudio = false {
        didSet {
            // mute local audio
            agoraKit.muteLocalAudioStream(isMutedAudio)
            audioMuteButton.isSelected = isMutedAudio
        }
    }
    
    private var isBeautyOn = false {
        didSet {
            // improve local render view
            agoraKit.setBeautyEffectOptions(isBeautyOn,
                                            options: isBeautyOn ? beautyOptions : nil)
            beautyEffectButton.isSelected = isBeautyOn
        }
    }
    
    private var isSwitchCamera = false {
        didSet {
            agoraKit.switchCamera()
        }
    }
    
    private var videoSessions = [VideoSession]() {
        didSet {
            placeholderView.isHidden = (videoSessions.count == 0 ? false : true)
            // update render view layout
            updateBroadcastersView()
        }
    }
    
    private let maxVideoSession = 500
    
    weak var dataSource: LiveVCDataSource?
    var isFromPush = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButtonsVisiablity()
        loadAgoraKit()
        
        eyeView.layer.cornerRadius = 5
        commentsTableView.register(UINib(nibName: "LiveVideoCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "LiveVideoCommentsTableViewCell")
        txtViewComment.layer.cornerRadius = txtViewComment.frame.height / 2
        txtViewComment.clipsToBounds = true
        txtViewComment.layer.borderWidth = 1
        txtViewComment.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtViewComment.text = "Comment"
        txtViewComment.textColor = UIColor.white.withAlphaComponent(0.5)
        txtViewComment.contentInset = UIEdgeInsets(top: 3, left: 10, bottom: 0, right: 5)
        txtViewComment.delegate = self
        
        commentRef.child(liveRoomName).observe(.childAdded) { (snapshot) in
            
            let userId = snapshot.childSnapshot(forPath: "userId").value as! Int
            let userName = snapshot.childSnapshot(forPath: "userName").value as! String
            let userImage = snapshot.childSnapshot(forPath: "userImage").value as! String
            let comment = snapshot.childSnapshot(forPath: "comment").value as! String
            let commentTime = snapshot.childSnapshot(forPath: "timestamp").value as! Double
            
            let model = LiveVideoCommentModel(userId: userId, username: userName, userImage: userImage, comment: comment, time: commentTime)
            self.commentsArray.append(model)
            self.commentsTableView.reloadData()
            self.commentsTableView.scrollToRow(at: IndexPath(row: self.commentsArray.count - 1, section: 0), at: .bottom, animated: true)
        }
        
//        let righToLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
//        righToLeftGesture.direction = .left
//        commentsView.addGestureRecognizer(righToLeftGesture)
//
//        let leftToRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
//        leftToRightGesture.direction = .right
//        commentsView.addGestureRecognizer(leftToRightGesture)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - ui action
    @IBAction func doSwitchCameraPressed(_ sender: UIButton) {
        isSwitchCamera.toggle()
    }
    
    @IBAction func doBeautyPressed(_ sender: UIButton) {
        isBeautyOn.toggle()
    }
    
    @IBAction func doMuteVideoPressed(_ sender: UIButton) {
        isMutedVideo.toggle()
    }
    
    @IBAction func doMuteAudioPressed(_ sender: UIButton) {
        isMutedAudio.toggle()
    }
    
    @IBAction func doLeavePressed(_ sender: UIButton) {
        leaveChannel()
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton){
        if (txtViewComment.text != "" && txtViewComment.text != "Comment"){
            postComment()
        }
    }
    
    func postComment(){
        commentRef.child(liveRoomName).childByAutoId().updateChildValues(
            ["userId": Utility.getLoginUserId(),
             "userName": Utility.getLoginUserFullName(),
             "userImage": Utility.getLoginUserImage(),
             "comment": txtViewComment.text!,
             "timestamp": ServerValue.timestamp()]
        )
        txtViewComment.text = "Comment"
        txtViewComment.textColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    @objc func swipeLeft(){
        commentsView.isHidden = true
        viewSlideInFromRightToLeft(views: commentsView)
    }
    
    @objc func swipeRight(){
        commentsView.isHidden = false
        viewSlideInFromLeftToRight(views: commentsView)
    }
    
    func viewSlideInFromRightToLeft(views: UIView) {
         var transition: CATransition? = nil
         transition = CATransition()
         transition!.duration = 0.5
         transition!.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
         transition!.type = CATransitionType.push
         transition!.subtype = CATransitionSubtype.fromRight
         transition!.delegate = self
         views.layer.add(transition!, forKey: nil)
        
//        UIView.transition(with: views, duration: 0.5, options: .curveEaseInOut, animations: {
//            views.isHidden = true
//        })
        
     }
    func viewSlideInFromLeftToRight(views: UIView) {
         var transition: CATransition? = nil
         transition = CATransition()
         transition!.duration = 0.5
         transition!.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
         transition!.type = CATransitionType.push
         transition!.subtype = CATransitionSubtype.fromLeft
         transition!.delegate = self
         views.layer.add(transition!, forKey: nil)
//        UIView.transition(with: views, duration: 0.5, options: .curveEaseInOut, animations: {
//            views.isHidden = false
//        })
     }
    
    func showStreamEndError(){
        
        let alert = UIAlertController(title: "This live stream has been ended", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            DispatchQueue.main.async {
                self.videoSessions.removeAll()
                if (self.isFromPush){
                    let vc = Utility.getTabBarViewController()
                    UIWINDOW!.rootViewController = vc
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension LiveRoomViewController: CAAnimationDelegate{
    
}

private extension LiveRoomViewController {
    func updateBroadcastersView() {
        // video views layout
        if videoSessions.count == maxVideoSession {
            broadcastersView.reload(level: 0, animated: true)
        } else {
            var rank: Int
            var row: Int
            
            if videoSessions.count == 0 {
                broadcastersView.removeLayout(level: 0)
                return
            } else if videoSessions.count == 1 {
                rank = 1
                row = 1
            } else if videoSessions.count == 2 {
                rank = 1
                row = 2
            } else {
                rank = 2
                row = Int(ceil(Double(videoSessions.count) / Double(rank)))
            }
            
            let itemWidth = CGFloat(1.0) / CGFloat(rank)
            let itemHeight = CGFloat(1.0) / CGFloat(row)
            let itemSize = CGSize(width: itemWidth, height: itemHeight)
            let layout = AGEVideoLayout(level: 0)
                        .itemSize(.scale(itemSize))
            
            broadcastersView
                .listCount { [unowned self] (_) -> Int in
                    return self.videoSessions.count
                }.listItem { [unowned self] (index) -> UIView in
                    return self.videoSessions[index.item].hostingView
                }
            
            broadcastersView.setLayouts([layout], animated: true)
        }
    }
    
    func updateButtonsVisiablity() {
        guard let sessionButtons = sessionButtons else {
            return
        }
        
        let isHidden = settings.role == .audience
        
        for item in sessionButtons {
            item.isHidden = isHidden
        }
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
}

private extension LiveRoomViewController {
    func getSession(of uid: UInt) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(of uid: UInt) -> VideoSession {
        if let fetchedSession = getSession(of: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
}

//MARK: - Agora Media SDK
private extension LiveRoomViewController {
    func loadAgoraKit() {
        guard let channelId = settings.roomName else {
            return
        }
        
        viewsRef.child(liveRoomName).observe(.value) { (snapshot) in
            if (snapshot.childrenCount > 0){
                self.totalViews = snapshot.childSnapshot(forPath: "count").value as! Int
                self.lblCount.text = self.totalViews > 0 ? "\(self.totalViews)" : "0"
            }
            
        }
        
        setIdleTimerActive(false)
        
        // Step 1, set delegate to inform the app on AgoraRtcEngineKit events
        agoraKit.delegate = self
        // Step 2, set live broadcasting mode
        // for details: https://docs.agora.io/cn/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/setChannelProfile:
        agoraKit.setChannelProfile(.liveBroadcasting)
        // set client role
        agoraKit.setClientRole(settings.role)
        
        // Step 3, Warning: only enable dual stream mode if there will be more than one broadcaster in the channel
        agoraKit.enableDualStreamMode(true)
        
        // Step 4, enable the video module
        agoraKit.enableVideo()
        // set video configuration
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: settings.dimension,
                frameRate: settings.frameRate,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: .adaptative
            )
        )
        
        // if current role is broadcaster, add local render view and start preview
        if settings.role == .broadcaster {
            addLocalSession()
            agoraKit.startPreview()
            self.eyeView.isHidden = false
            self.commentsView.isHidden = false
        }
        
        // Step 5, join channel and start group chat
        // If join  channel success, agoraKit triggers it's delegate function
        // 'rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int)'
        agoraKit.joinChannel(byToken: "", channelId: channelId, info: nil, uid: UInt(Utility.getLoginUserId()), joinSuccess: nil)
        
        // Step 6, set speaker audio route
        agoraKit.setEnableSpeakerphone(true)
        
        if (settings.role == .audience){
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let count = self.totalViews + 1
                self.viewsRef.child(self.liveRoomName).updateChildValues(["count": count])
            }
            
            
        }
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        localSession.updateInfo(fps: settings.frameRate.rawValue)
        videoSessions.append(localSession)
        agoraKit.setupLocalVideo(localSession.canvas)
    }
    
    func leaveChannel() {
        // Step 1, release local AgoraRtcVideoCanvas instance
        agoraKit.setupLocalVideo(nil)
        // Step 2, leave channel and end group chat
        agoraKit.leaveChannel(nil)
        
        // Step 3, if current role is broadcaster,  stop preview after leave channel
        if settings.role == .broadcaster {
            agoraKit.stopPreview()
        }
        
        setIdleTimerActive(true)
        
        if (settings.role == .audience){
            let count = totalViews - 1
            viewsRef.child(liveRoomName).updateChildValues(["count": count])
        }
        
        if (isFromPush){
            let vc = Utility.getTabBarViewController()
            UIWINDOW!.rootViewController = vc
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}

// MARK: - AgoraRtcEngineDelegate
extension LiveRoomViewController: AgoraRtcEngineDelegate {
    
    /// Occurs when the first local video frame is displayed/rendered on the local video view.
    ///
    /// Same as [firstLocalVideoFrameBlock]([AgoraRtcEngineKit firstLocalVideoFrameBlock:]).
    /// @param engine  AgoraRtcEngineKit object.
    /// @param size    Size of the first local video frame (width and height).
    /// @param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK calls this callback.
    ///
    /// If the [startPreview]([AgoraRtcEngineKit startPreview]) method is called before the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, then `elapsed` is the time elapsed from calling the [startPreview]([AgoraRtcEngineKit startPreview]) method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        if let selfSession = videoSessions.first {
            selfSession.updateInfo(resolution: size)
        }
    }
    
    /// Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        if (videoSessions.count == 0){
            agoraKit.leaveChannel { (channel) in
                self.showStreamEndError()
                return
            }
            
        }
        if let selfSession = videoSessions.first {
            self.eyeView.isHidden = false
            self.commentsView.isHidden = false
            selfSession.updateChannelStats(stats)
        }
    }
    
    
    /// Occurs when the first remote video frame is received and decoded.
    /// - Parameters:
    ///   - engine: AgoraRtcEngineKit object.
    ///   - uid: User ID of the remote user sending the video stream.
    ///   - size: Size of the video frame (width and height).
    ///   - elapsed: Time elapsed (ms) from the local user calling the joinChannelByToken method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        guard videoSessions.count <= maxVideoSession else {
            return
        }
        
        let userSession = videoSession(of: uid)
        userSession.updateInfo(resolution: size)
        agoraKit.setupRemoteVideo(userSession.canvas)
    }
    
    /// Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as [userOfflineBlock]([AgoraRtcEngineKit userOfflineBlock:]).
    ///
    /// There are two reasons for users to be offline:
    ///
    /// - Leave a channel: When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
    /// - Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the Live-broadcast profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so Agora recommends using a signaling system for more reliable offline detection.
    ///
    ///  @param engine AgoraRtcEngineKit object.
    ///  @param uid    ID of the user or host who leaves a channel or goes offline.
    ///  @param reason Reason why the user goes offline, see AgoraUserOfflineReason.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerated() where session.uid == uid {
            indexToDelete = index
            break
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            
            // release canvas's view
            deletedSession.canvas.view = nil
        }
        videoSessions.removeAll()
        agoraKit.leaveChannel { (channel) in
            self.showStreamEndError()
            return
        }
    }
    
    /// Reports the statistics of the video stream from each remote user/host.
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        if let session = getSession(of: stats.uid) {
            session.updateVideoStats(stats)
        }
    }
    
    /// Reports the statistics of the audio stream from each remote user/host.
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        if let session = getSession(of: stats.uid) {
            session.updateAudioStats(stats)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, rtmpStreamingChangedToState url: String, state: AgoraRtmpStreamingState, errorCode: AgoraRtmpStreamingErrorCode) {
        
    }
    
    /// Reports a warning during SDK runtime.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning code: \(warningCode.description)")
    }
    
    /// Reports an error during SDK runtime.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("warning code: \(errorCode.description)")
    }
}

extension LiveRoomViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveVideoCommentsTableViewCell", for: indexPath) as! LiveVideoCommentsTableViewCell
        let comment = commentsArray[indexPath.row]
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
        cell.userImageView.clipsToBounds = true
        cell.userImageView.sd_setImage(with: URL(string: comment.commentUserImage), placeholderImage: UIImage(named: "editProfilePlaceholder"))
        cell.lblUsername.text = comment.commentUserName
        cell.lblComment.text = comment.comment
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension LiveRoomViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Comment"){
            textView.text = ""
        }
        textView.textColor = .white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == ""){
            textView.text = "Comment"
            textView.textColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
}
