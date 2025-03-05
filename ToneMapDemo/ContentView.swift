//
//  ContentView.swift
//  ToneMapDemo
//
//  Created by Jeffrey Blagdon on 2025-02-25.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State private var isHDR: Bool = true
    @State private var sdrPlayer: AVPlayer?
    @State private var errorMessage: String?
    var body: some View {
        VStack {
            Button(action: { isHDR.toggle() }, label: {
                Text(isHDR ? "HDR": "Tone-mapped SDR")
            })
            if isHDR {
                hdrPlayerView
            } else {
                sdrPlayerView
                    .task {
                        do {
                            self.sdrPlayer = try await self.loadSDRPlayer()
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
            }
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .padding()
    }
    
    private var hdrPlayerView: some View {
        let hdrURL = Bundle.main.url(forResource: "hdr", withExtension: "mov")!
        return VideoPlayer(player: AVPlayer(url: hdrURL))
    }
    
    @ViewBuilder
    private var sdrPlayerView: some View {
        if let sdrPlayer {
            VideoPlayer(player: sdrPlayer)
        } else {
            ProgressView()
        }
    }
    
    enum Error: Swift.Error {
        case cantLoadTracks
    }
    
    private func loadSDRPlayer() async throws -> AVPlayer {
        let sdrURL = Bundle.main.url(forResource: "sdr", withExtension: "mov")!
        let asset = AVURLAsset(url: sdrURL)
        let playerItem = AVPlayerItem(asset: asset)
        let videoComposition = try await AVMutableVideoComposition.videoComposition(with: asset, applyingCIFiltersWithHandler: { request in
            let sourceImage = request.sourceImage
            let filter = ToneMapFilter()
            filter.inputImage = sourceImage
            request.finish(with: filter.outputImage!, context: nil)
        })
        videoComposition.colorPrimaries = AVVideoColorPrimaries_ITU_R_2020
        videoComposition.colorTransferFunction = AVVideoTransferFunction_SMPTE_ST_2084_PQ
        videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_2020
        playerItem.videoComposition = videoComposition
        return AVPlayer(playerItem: playerItem)
    }
}
