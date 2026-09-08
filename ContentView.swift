import SwiftUI
import MediaPlayer
import AVFoundation

struct ContentView: View {
    @State private var isExpanded = false
    @State private var songTitle = "Müzik Çalmıyor"
    @State private var artistName = "Spotify veya Apple Music Açın"
    @State private var isPlaying = false
    @State private var albumArt: UIImage? = nil
    @State private var waveHeights: [CGFloat] = [10, 15, 8, 18]
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    if isExpanded {
                        // --- Genişletilmiş Çentik Modu ---
                        HStack(spacing: 12) {
                            if let art = albumArt {
                                Image(uiImage: art)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(10)
                                    .clipped()
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "music.note")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(songTitle)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(artistName)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            
                            Spacer(minLength: 0)
                            
                            HStack(spacing: 16) {
                                Button(action: togglePlayPause) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: nextTrack) {
                                    Image(systemName: "forward.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.trailing, 4)
                        }
                        .padding(.horizontal, 14)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        // --- Kapalı Çentik Modu ---
                        HStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            Text(isPlaying ? songTitle : "Dynamic Island Pro")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if isPlaying {
                                HStack(spacing: 2) {
                                    ForEach(0..<4) { index in
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(Color.green)
                                            .frame(width: 2.5, height: waveHeights[index])
                                    }
                                }
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 14)
                        .transition(.opacity)
                    }
                }
                .padding(.vertical, isExpanded ? 12 : 8)
                .frame(width: isExpanded ? 350 : 210, height: isExpanded ? 76 : 36)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 32 : 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: isExpanded ? 32 : 18, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 8)
                .onTapGesture {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.7, blendDuration: 0)) {
                        isExpanded.toggle()
                    }
                }
                .padding(.top, 8)
            }
        }
        .onReceive(timer) { _ in
            fetchNowPlayingInfo()
            if isPlaying {
                withAnimation(.easeInOut(duration: 0.2)) {
                    waveHeights = waveHeights.map { _ in CGFloat.random(in: 4...14) }
                }
            }
        }
        .onAppear {
            fetchNowPlayingInfo()
        }
    }

    func fetchNowPlayingInfo() {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        if let nowPlaying = musicPlayer.nowPlayingItem {
            self.songTitle = nowPlaying.title ?? "Bilinmeyen Parça"
            self.artistName = nowPlaying.artist ?? "Bilinmeyen Sanatçı"
            self.isPlaying = musicPlayer.playbackState == .playing
            
            if let artwork = nowPlaying.artwork {
                self.albumArt = artwork.image(at: CGSize(width: 120, height: 120))
            }
        }
    }

    func togglePlayPause() {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        if musicPlayer.playbackState == .playing {
            musicPlayer.pause()
            isPlaying = false
        } else {
            musicPlayer.play()
            isPlaying = true
        }
    }

    func nextTrack() {
        MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
        fetchNowPlayingInfo()
    }
}
