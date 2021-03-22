//
//  ZFIJKPlayerUIView.swift
//  kjxq
//
//  Created by Spec on 2020/12/7.
//

import Foundation
import UIKit
//import SpFly
class ZFIJKPlayerUIView: UIView {
    
    private(set) var player: ZFPlayerController!
    lazy var controlView: ZFPlayerControlView = {
       let control = ZFPlayerControlView()
        control.fastViewAnimated = true
        control.autoHiddenTimeInterval = 5
        control.autoFadeTimeInterval = 0.5
        control.prepareShowLoading = true
        control.prepareShowControlView = false
        return control
    }()
    
    
    lazy var playBtn: UIButton = {
       let btn = UIButton()
        btn.setImage(UIImage(named: "new_allPlay_44x44_"), for: .normal)
//        btn.addTarget(self, action: #selector(playClick), for: .touchUpInside)
        return btn
    }()
    
    let blackImg = ZFUtilities.image(with: UIColor.black, size: CGSize(width: 1, height: 1))
    let coverImgStr = "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"
    lazy var containerView: UIImageView = {
        let view = UIImageView()
        view.setImageWithURLString(coverImgStr, placeholder: blackImg)
        return view
    }()
    
    private(set) var state: State = .none {
        didSet { stateDidChanged(state: state, previous: oldValue) }
    }
    private(set) var pausedReason: PausedReason = .waitingKeepUp
    var stateDidChanged: ((State) -> Void)?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = bounds
    }

    init(frame: CGRect, manager: ZFIJKPlayerManager) {
        
            super.init(frame: frame)
        addSubview(containerView)
//        containerView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: 120)
        
//        containerView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        backgroundColor = .red
        containerView.backgroundColor = .red
        self.player = ZFPlayerController.player(withPlayerManager: manager, containerView: containerView)
        
        // config
        player.controlView = controlView
        player.pauseWhenAppResignActive = false
        manager.shouldAutoPlay = true
        
//        player.orientationWillChange = { (play, isFullScreen) in
//            screenViewModel.allowOrentitaionRotation = isFullScreen
//        }
        
        manager.playerPlayStateChanged = {  playback, state in
            switch state {
            case .playStatePlaying:
                self.state = .playing
            case .playStatePaused:
                self.state = .paused(playProgress: manager.currentTime, bufferProgress: manager.bufferTime)
            default: break
            }
        }
        
        manager.playerDidToEnd = { playback in
            self.state = .none
        }
        
        manager.playerPlayFailed = { playback, error in
            if let err = error as? NSError {
                self.state = .error(err)
            }
//            self.state = .error(data)
        }
        
        manager.playerPrepareToPlay = { playback, url in
            self.state = .loading
        }
    
        manager.playerReadyToPlay = { playback, url in
            if self.player.shouldAutoPlay {
            self.state = .playing
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ZFIJKPlayerUIView {
    
    func play(with string: String) {
        
        guard let url = URL(string: string) else {
            return
        }
//        player.assetURLs = [url]
//        player.playTheNext()
        state = .none
        player.assetURL = url
    }
    
    func play(with url: URL) {
        state = .none
        player.assetURL = url
    }
    
    func pause() {
//        player.stop()
        player.currentPlayerManager.pause()
    }
    
    func seek(to time: TimeInterval) {
        player.seek(toTime: time) { (result) in
            print("pause time result = \(result)")
        }
    }
    
}

extension ZFIJKPlayerUIView {
    func stateDidChanged(state: State, previous: State) {
        
        guard state != previous else {
            return
        }
        
        switch state {
        case .playing, .paused: isHidden = false
        default:                isHidden = true
        }
        
        stateDidChanged?(state)
    }
}
extension ZFIJKPlayerUIView.State: Equatable {
    
    public static func == (lhs: ZFIJKPlayerUIView.State, rhs: ZFIJKPlayerUIView.State) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.loading, .loading):
            return true
        case (.playing, .playing):
            return true
        case let (.paused(p1, b1), .paused(p2, b2)):
            return (p1 == p2) && (b1 == b2)
        case let (.error(e1), .error(e2)):
            return e1 == e2
        default:
            return false
        }
    }
    
}
extension ZFIJKPlayerUIView {
    /*
    func setupPlayer() {
        
        let manger = ZFIJKPlayerManager()
        
        manger.shouldAutoPlay = true
        
        let player = ZFPlayerController.player(withPlayerManager: manger, containerView: containerView)
        player.controlView = self.controlView
        
        player.pauseWhenAppResignActive = false
        
//        player.resumePlayRecord = false
        
        player.orientationWillChange = {(player, isFullScreen) in
            screenViewModel.allowOrentitaionRotation = isFullScreen
        }
        
        player.playerDidToEnd = { [unowned self] asset in
            if player.isLastAssetURL {
                player.playTheNext()
                self.controlView.showTitle("", coverURLString: self.coverImgStr, fullScreenMode: ZFFullScreenMode.landscape)
            } else {
                player.stop()
            }
        }
        
        player.playerPlayFailed = { aset, er in
            print(er)
        }
        
        self.player = player
    }
    */
}



import SwiftUI

// old version
var zfIjkPlayerUIView: ZFIJKPlayerUIView?
//struct ZFIJKPlayerView: UIViewRepresentable {
//    
//    @Binding var urlStr: String
//    
//    typealias UIViewType = ZFIJKPlayerUIView
//    
//    func makeUIView(context: Context) -> ZFIJKPlayerUIView {
//        if let view = zfIjkPlayerUIView {
//            return view
//        }
//        let view = ZFIJKPlayerUIView()
//       
//        zfIjkPlayerUIView = view
//        return view
//    }
//    
//    func updateUIView(_ uiView: ZFIJKPlayerUIView, context: Context) {
//        
//        if !urlStr.isEmpty {
//            uiView.play(with: urlStr)
//        } else {
//            uiView.player.stop()
////            uiView.pause()
//        }
//    }
//}

// 这里还是要自定一个状态
// 通过状态改变处理
// 捕获 失败原因 暂停 停止等等
extension ZFIJKPlayerUIView {
//    func convertState() -> ZFIJKPlayer.State {
//        switch player.currentPlayerManager.playState {
//        case .playStateUnknown:
//            break
//        case .playStatePaused:
//            return .paused(playProgress: player.currentTime, bufferProgress: player.bufferTime)
//        case .playStatePlayFailed:
//            return .error(Error())
//        case .playStatePlaying:
//            return .playing(totalDuration: player.totalTime)
//        case .playStatePlayStopped:
//            return .paused(playProgress: <#T##Double#>, bufferProgress: <#T##Double#>)
//        }
//    }
    
    func convertState() -> ZFIJKPlayer.State {
        switch state {
        case .none, .loading:
            return .loading
        case .playing:
            return .playing(totalDuration: player.totalTime)
        case .paused(let p, let b):
            return .paused(playProgress: p, bufferProgress: b)
        case .error(let error):
            return .error(error)
        }
    }
}

extension ZFIJKPlayerUIView {
    enum State {
        
        /// None
        case none
        
        /// From the first load to get the first frame of the video
        case loading
        
        /// Playing now
        case playing
        
        /// Pause, will be called repeatedly when the buffer progress changes
        case paused(playProgress: Double, bufferProgress: Double)
        
        /// An error occurred and cannot continue playing
        case error(NSError)
    }
    
    enum PausedReason: Int {
        
        /// Pause because the player is not visible, stateDidChanged is not called when the buffer progress changes
        case hidden
        
        /// Pause triggered by user interaction, default behavior
        case userInteraction
        
        /// Waiting for resource completion buffering
        case waitingKeepUp
    }
}
