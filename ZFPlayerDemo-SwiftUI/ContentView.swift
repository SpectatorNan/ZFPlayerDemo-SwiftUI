//
//  ContentView.swift
//  ZFPlayerDemo-SwiftUI
//
//  Created by 楠 on 2021/3/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var play = true
    @State var url = URL(string: "http://vfx.mtime.cn/Video/2019/06/05/mp4/190605101703931259.mp4")!
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                
                ZFIJKPlayer(url: url, play: $play)
                 .frame(height: 200)
                
                Button(action: {
                    play.toggle()
                }, label: {
                    Text("播放/暂停")
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
