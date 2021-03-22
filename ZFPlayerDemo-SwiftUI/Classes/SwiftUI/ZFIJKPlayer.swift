//
//  ZFIJKPlayer.swift
//  kjxq
//
//  Created by Spec on 2021/3/18.
//

import SwiftUI

struct ZFIJKPlayer {
    
    enum State {
        case loading
        case playing(totalDuration: Double)
        case paused(playProgress: Double, bufferProgress: Double)
        case error(Error)
    }
    
    private(set) var url: URL
    private var config = Config()
    
    @Binding private var play: Bool
    @Binding private var time: TimeInterval
    
    let playerManager = ZFIJKPlayerManager()
    
    init(url: URL, play: Binding<Bool>, time: Binding<TimeInterval> = .constant(.zero)) {
        self.url = url
        self._play = play
        self._time = time
    }
    /*
    public enum State {
        
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
    public enum PausedReason: Int {
        
        /// Pause because the player is not visible, stateDidChanged is not called when the buffer progress changes
        case hidden
        
        /// Pause triggered by user interaction, default behavior
        case userInteraction
        
        /// Waiting for resource completion buffering
        case waitingKeepUp
    }
    
    private(set) var playerURL: URL?
    private(set) var state: State = .none {
        didSet { stateDidChanged(state: state, previous: oldValue) }
    }
    
    /// Playback status changes, such as from play to pause.
    open var stateDidChanged: ((State) -> Void)?
    */
}

extension ZFIJKPlayer {
    struct Config {
        struct Handler {
            var onBufferChanged: ((Double) -> Void)?
            var onPlayToEndTime: (() -> Void)?
            var onReplay: (() -> Void)?
            var onStateChanged: ((State) -> Void)?
        }
        
        var autoReplay: Bool = false
        var mute: Bool = false
        var contentMode: UIView.ContentMode = .scaleToFill
        
        var handler: Handler = Handler()
    }
    
    /// Whether the video will be automatically replayed until the end of the video playback.
    func autoReplay(_ value: Bool) -> Self {
        var view = self
        view.config.autoReplay = value
        return view
    }
    
    /// Whether the video is muted, only for this instance.
    func mute(_ value: Bool) -> Self {
        var view = self
        view.config.mute = value
        return view
    }
    
    /// A string defining how the video is displayed within an AVPlayerLayer bounds rect.
    /// scaleAspectFill -> resizeAspectFill, scaleAspectFit -> resizeAspect, other -> resize
    func contentMode(_ value: UIView.ContentMode) -> Self {
        var view = self
        view.config.contentMode = value
        return view
    }
    
    /// Trigger a callback when the buffer progress changes,
    /// the value is between 0 and 1.
    func onBufferChanged(_ handler: @escaping (Double) -> Void) -> Self {
        var view = self
        view.config.handler.onBufferChanged = handler
        return view
    }
    
    /// Playing to the end.
    func onPlayToEndTime(_ handler: @escaping () -> Void) -> Self {
        var view = self
        view.config.handler.onPlayToEndTime = handler
        return view
    }
    
    /// Replay after playing to the end.
    func onReplay(_ handler: @escaping () -> Void) -> Self {
        var view = self
        view.config.handler.onReplay = handler
        return view
    }
    
    /// Playback status changes, such as from play to pause.
    func onStateChanged(_ handler: @escaping (State) -> Void) -> Self {
        var view = self
        view.config.handler.onStateChanged = handler
        return view
    }
}



// new version
extension ZFIJKPlayer: UIViewRepresentable {

    
    
     func makeUIView(context: Context) -> ZFIJKPlayerUIView {
        if let view = zfIjkPlayerUIView {
            return view
        }
        
        let uiView = ZFIJKPlayerUIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), manager: playerManager)
        
        playerManager.playerDidToEnd = { asset in
            if self.config.autoReplay == false {
                self.play = false
            }
            DispatchQueue.main.async {
                self.config.handler.onPlayToEndTime?()
            }
        }
        
//        uiView.player.containerView.contentMode = config.contentMode
//        uiView.containerView.contentMode = config.contentMode
        
        playerManager.playerPlayStateChanged = { mediaPlayback, state in
            
            let state: State = uiView.convertState()
            
//            if case .playing = state {
//                context.coordinator.startObserver(uiView: uiView)
//            } else {
//                context.coordinator.stopObserver(uiView: uiView)
//            }
            
            DispatchQueue.main.async {
                self.config.handler.onStateChanged?(state)
            }
        }
        zfIjkPlayerUIView = uiView
        return uiView
    }
    
     func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    func updateUIView(_ uiView: ZFIJKPlayerUIView, context: Context) {
        if context.coordinator.observingURL != url {
            context.coordinator.clean()
            context.coordinator.observingURL = url
        }
        play ? uiView.play(with: url) : playerManager.pause()
        playerManager.isMuted = config.mute
        
        if let observerTime = context.coordinator.observerTime, time != observerTime {
            uiView.seek(to: time)
        }
        
//        playerManager.rate = 2
        
//        play ? uiView.play(for: url) : uiView.pause(reason: .userInteraction)
//        uiView.isMuted = config.mute
//        uiView.isAutoReplay = config.autoReplay
//
//        if let observerTime = context.coordinator.observerTime, time != observerTime {
//            uiView.seek(to: time, toleranceBefore: time, toleranceAfter: time, completion: { _ in })
//        }
    }
    
    
     class Coordinator: NSObject {
        var videoPlayer: ZFIJKPlayer
        var observingURL: URL?
        var observer: Any?
        var observerTime: TimeInterval?
        var observerBuffer: Double?

        init(_ videoPlayer: ZFIJKPlayer) {
            self.videoPlayer = videoPlayer
        }
        
        func startObserver(uiView: ZFIJKPlayerUIView) {
            guard observer == nil else { return }
            
//            observer = uiView.addPeriodicTimeObserver(forInterval: .init(seconds: 0.25, preferredTimescale: 60)) { [weak self, unowned uiView] time in
//                guard let `self` = self else { return }
//
//                self.videoPlayer.time = time
//                self.observerTime = time
//
//                self.updateBuffer(uiView: uiView)
//            }
        }
        
        func stopObserver(uiView: ZFIJKPlayerUIView) {
            guard let observer = observer else { return }
            
//            uiView.removeTimeObserver(observer)
            
            self.observer = nil
        }
        
        func clean() {
            self.observingURL = nil
            self.observer = nil
            self.observerTime = nil
            self.observerBuffer = nil
        }
        
        func updateBuffer(uiView: ZFIJKPlayerUIView) {
//            guard let handler = videoPlayer.config.handler.onBufferChanged else { return }
//
//            let bufferProgress = uiView.bufferProgress
//
//            guard bufferProgress != observerBuffer else { return }
//
//            DispatchQueue.main.async { handler(bufferProgress) }
            
//            observerBuffer = bufferProgress
        }
    }
}


extension ZFIJKPlayer {
//    func stateDidChanged(state: State, previous: State) {
//
//        guard state != previous else {
//            return
//        }
//
//        switch state {
//        case .playing, .paused: isHidden = false
//        default:                isHidden = true
//        }
//
//        stateDidChanged?(state)
//    }
}
//extension ZFIJKPlayer.State: Equatable {
    
//    static func == (lhs: ZFIJKPlayer.State, rhs: ZFIJKPlayer.State) -> Bool {
//        switch (lhs, rhs) {
//        case (.none, .none):
//            return true
//        case (.loading, .loading):
//            return true
//        case (.playing, .playing):
//            return true
//        case let (.paused(p1, b1), .paused(p2, b2)):
//            return (p1 == p2) && (b1 == b2)
//        case let (.error(e1), .error(e2)):
//            return e1 == e2
//        default:
//            return false
//        }
//    }
    
//}


extension ZFIJKPlayer {
    
    func playClick() {}
}
