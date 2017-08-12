//
//  Connection.swift
//  webrtcExample
//
//  Created by 河瀬悠 on 2017/08/08.
//  Copyright © 2017年 NakadoriBooks. All rights reserved.
//

import UIKit

typealias ConnectionOnAddedStream = (_ stream:RTCMediaStream)->()

class Connection: NSObject {

    private let wamp:Wamp
    private let onAddedStream:ConnectionOnAddedStream
    private var webRtc:WebRTC!
    private let myId:String
    let targetId:String
    private var _remoteStream:RTCMediaStream?
    
    init(myId:String, targetId:String, wamp:Wamp, onAddedStream:@escaping ConnectionOnAddedStream){
        self.myId = myId
        self.targetId = targetId
        self.wamp = wamp
        self.onAddedStream = onAddedStream
        
        super.init()
        
        webRtc = WebRTC(callbacks: (
            onCreateOffer: {(sdp:NSDictionary) -> Void in
                
                let jsonData = try! JSONSerialization.data(withJSONObject: sdp, options: [])
                let jsonStr = String(bytes: jsonData, encoding: .utf8)!
                
                self.wamp.publishOffer(targetId: targetId, sdp: jsonStr)
            }
            , onCreateAnswer: {(sdp:NSDictionary) -> Void in
                
                let jsonData = try! JSONSerialization.data(withJSONObject: sdp, options: [])
                let jsonStr = String(bytes: jsonData, encoding: .utf8)!
                
                self.wamp.publishAnswer(targetId: targetId, sdp: jsonStr)
            }
            , onIceCandidate: {(iceCandidate:NSDictionary) -> Void in

                let jsonData = try! JSONSerialization.data(withJSONObject: iceCandidate, options: [])
                let jsonStr = String(bytes: jsonData, encoding: .utf8)!
                
                self.wamp.publishCandidate(targetId: targetId, candidate: jsonStr)
            }
            , onAddedStream: {(stream:RTCMediaStream) -> Void in
                self._remoteStream = stream
                self.onAddedStream(stream)
            }
            , onRemoveStream: {(stream:RTCMediaStream) -> Void in
                
            }
        ))
        
    }
    
    deinit {
        print("connection deinit")
    }
    
    // MARK: interface
    
    var remoteStream:RTCMediaStream?{
        get{
            return _remoteStream
        }
    }
    
    func receiveOffer(offerSdp:NSDictionary){
        webRtc.receiveOffer(remoteSdp: offerSdp)
    }
    
    func publishOffer(){
        print("publishOffer")
        webRtc.createOffer()
    }
    
    func receiveAnswer(sdp:NSDictionary){
        webRtc.receiveAnswer(remoteSdp: sdp)
    }
    
    func receiveCandidate(candidate:NSDictionary){
        webRtc.receiveCandidate(candidate: candidate)
    }
    
    func close(){
        print("close connection")
        webRtc.close()
    }
    
}
