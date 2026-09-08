import SwiftUI
import MediaPlayer

struct ContentView: View {
    @State private var isExpanded = false
    @State private var songTitle = "Müzik Çalmıyor"
    @State private var artistName = "Spotify veya Apple Music Açın"
    @State private var isPlaying = false
    @State private var albumArt: UIImage? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            // Çentik / Dynamic Island Bileşeni
            VStack {
                HStack {
                    if isExpanded {
                        // Albüm Kapağı / İkon
                        if let art = albumArt {
                            Image(uiImage: art)
                                .resizable()
                                .frame(width: 45, height: 45)
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 45, height: 45)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .foregroundColor(.white)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(songTitle)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(artistName)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Oynatma Kontrolleri
                        HStack(spacing: 15) {
                            Button(action: togglePlayPause) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                            }
                            
                            Button(action: nextTrack) {
                                Image(systemName: "forward.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                        }
                    } else {
                        // Kapalı Hal (Çentik Modu)
                        Image(systemName: isPlaying ? "wave.3.right" : "music.note")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        Text(isPlaying ? songTitle : "Dynamic Island")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if isPlaying {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(Color.black)
            .cornerRadius(isExpanded ? 25 : 18)
            .overlay(
                RoundedRectangle(cornerRadius: isExpanded ? 25 : 18)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .frame(width: isExpanded ? 340 : 180, height: isExpanded ? 75 : 35)
            .padding(.top, 10)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }
            .onReceive(timer) { _ in
                fetchNowPlayingInfo()
            }
        }
        .onAppear {
            fetchNowPlayingInfo()
        }
    }

    // Arka planda çalan müziği çekme fonksiyonu
    func fetchNowPlayingInfo() {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        if let nowPlaying = musicPlayer.nowPlayingItem {
            self.songTitle = nowPlaying.title ?? "Bilinmeyen Şarkı"
            self.artistName = nowPlaying.artist ?? "Bilinmeyen Sanatçı"
            self.isPlaying = musicPlayer.playbackState == .playing
            
            if let artwork = nowPlaying.artwork {
                self.albumArt = artwork.image(at: CGSize(width: 100, height: 100))
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
