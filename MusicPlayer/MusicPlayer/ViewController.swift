//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 梁川 将和 on 2018/05/06.
//  Copyright © 2018年 Yanagawa Masakazu. All rights reserved.
//

import UIKit
import MediaPlayer
import AutoScrollLabel

let w = UIScreen.main.bounds.size.width
let h = UIScreen.main.bounds.size.height
class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    let artistLabel = CBAutoScrollLabel(frame: CGRect(x: 0, y: w + 160, width: w, height: 30))
    let albumLabel = CBAutoScrollLabel(frame: CGRect(x: 0, y: w + 100, width: w, height: 30))
    let songLabel = CBAutoScrollLabel(frame: CGRect(x: 0, y: w + 130, width: w, height: 30))
    let imageView = UIImageView(frame: CGRect(x: 0, y: 100, width: w, height: w))
    var playpause = UIButton(frame: CGRect(x: (w - 60) / 2, y: 580, width: 60, height: 60))
    let reb = UIButton(frame: CGRect(x:(w - 60) / 4, y: 580, width: 60, height: 60))
    var player: MPMusicPlayerController!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .darkGray
        player = MPMusicPlayerController.systemMusicPlayer
        player.repeatMode = MPMusicRepeatMode.none
        // プレイヤーを止める
        player.stop()
        
        // 再生中のItemが変わった時に通知を受け取る
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(type(of: self).b(notification:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        notificationCenter.addObserver(self, selector: #selector(type(of: self).nowPlayingItemChanged(notification:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        // 通知の有効化
        player.beginGeneratingPlaybackNotifications()
        
        artistLabel.font = UIFont.systemFont(ofSize: 15.0)
        artistLabel.textAlignment = .center
        artistLabel.textColor = .white
        artistLabel.labelSpacing = 50;
        artistLabel.pauseInterval = 3;
        artistLabel.scrollSpeed = 50.0;
        artistLabel.fadeLength = 20.0;
        view.addSubview(artistLabel)
        
        
        albumLabel.font = UIFont.systemFont(ofSize: 15.0)
        albumLabel.textAlignment = .center
        albumLabel.textColor = .white
        albumLabel.labelSpacing = 50;
        albumLabel.pauseInterval = 3;
        albumLabel.scrollSpeed = 50.0;
        albumLabel.fadeLength = 20.0;
        view.addSubview(albumLabel)
        
        
        songLabel.font = UIFont.boldSystemFont(ofSize: 30.0)
        songLabel.textAlignment = .center
        songLabel.textColor = .white
        songLabel.labelSpacing = 50;
        songLabel.pauseInterval = 3;
        songLabel.scrollSpeed = 50.0;
        songLabel.fadeLength = 20.0;
        view.addSubview(songLabel)
        
        view.addSubview(imageView)
        
        //再生・一時停止ボタン配置
        view.addSubview(playpause)
        
        let b = UIButton(frame: CGRect(x: w - 60, y: 30, width: 50, height: 50))
        b.layer.cornerRadius = 25.0
        b.setTitleColor(UIColor.white, for: UIControlState())
        b.backgroundColor = UIColor.rgb(r: 255, g: 15, b:115, alpha: 1.0)
        b.setTitle("+", for: UIControlState())
        b.addTarget(self, action: #selector(selecter(_:)), for: .touchUpInside)
        view.addSubview(b)
        
        
        let playStatus = player.playbackState
        if playStatus == .stopped {
            playpause.setImage(UIImage(named :"play.png"), for: UIControlState())
            playpause.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
        }
        else if playStatus == .paused {
            playpause.setImage(UIImage(named :"play.png"), for: UIControlState())
            playpause.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
        }
        
        let stop = UIButton(frame: CGRect(x: (w - 60) / 4 * 3, y: 580, width: 60, height: 60))
        stop.setImage(UIImage(named :"stop.png"), for: UIControlState())
        stop.addTarget(self, action: #selector(Stop(_:)), for: .touchUpInside)
        view.addSubview(stop)
        
        
        reb.setImage(UIImage(named: "repeat.png"), for: UIControlState())
        reb.addTarget(self, action: #selector(ChangeRepeat(_:)), for: .touchUpInside)
        view.addSubview(reb)
        
        //現在再生中の音楽を表示
        let playing = player.nowPlayingItem
        player.skipToBeginning()
        
        // 選択した曲から最初の曲の情報を表示
        if let mediaItem = playing {
            updateSongInformationUI(mediaItem : mediaItem)
        }
        
        
        
        
    }
    
    
    
    @objc func selecter(_ :UIButton){
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択にする。（falseにすると、単数選択になる）
        picker.allowsPickingMultipleItems = false
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
    }
    
    
    @objc func play(_ :UIButton){
        player.play()
        playpause.setImage(UIImage(named :"pause.png"), for: UIControlState())
        playpause.addTarget(self, action: #selector(Pause(_:)), for: .touchUpInside)
    }
    
    @objc func Pause(_ :UIButton){
        player.pause()
        playpause.setImage(UIImage(named :"play.png"), for: UIControlState())
        playpause.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
    }
    
    @objc func Stop(_ :UIButton){
        player.stop()
        player.skipToBeginning()
        playpause.setImage(UIImage(named :"play.png"), for: UIControlState())
        playpause.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
    }
    
    @objc func ChangeRepeat(_ : UIButton){
        player.repeatMode = .one
        reb.setImage(UIImage(named: "deleterepeat.png"), for: UIControlState())
        reb.addTarget(self, action: #selector(ChangeRepeatStop(_:)), for: .touchUpInside)

    }
    
    @objc func ChangeRepeatStop(_ : UIButton){
        player.repeatMode = .none
        reb.setImage(UIImage(named: "repeat.png"), for: UIControlState())
        reb.addTarget(self, action: #selector(ChangeRepeat(_:)), for: .touchUpInside)
    }
    
    
    /// メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)  {
        
        // プレイヤーを止める
        player.stop()
        
        // 選択した曲情報がmediaItemCollectionに入っているので、これをplayerにセット。
        player.setQueue(with: mediaItemCollection)
        
        //プレイヤーを再生
        player.play()
        
        // 選択した曲から最初の曲の情報を表示
        if let mediaItem = mediaItemCollection.items.first {
            updateSongInformationUI(mediaItem : mediaItem)
            
            playpause.setImage(UIImage(named :"pause.png"), for: UIControlState())
            playpause.addTarget(self, action: #selector(Pause(_:)), for: .touchUpInside)
            
            
        }
        
        // ピッカーを閉じる
        dismiss(animated: true, completion: nil)
        
    }
    
    
    /// 選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    /// 曲情報を表示する
    func updateSongInformationUI(mediaItem: MPMediaItem) {
        
        // 曲情報表示
        artistLabel.text = mediaItem.artist ?? "不明なアーティスト"
        artistLabel.labelSpacing = 50;
        artistLabel.pauseInterval = 3;
        artistLabel.scrollSpeed = 50.0;
        artistLabel.fadeLength = 20.0;
        albumLabel.text = mediaItem.albumTitle ?? "不明なアルバム"
        albumLabel.labelSpacing = 50;
        albumLabel.pauseInterval = 3;
        albumLabel.scrollSpeed = 50.0;
        albumLabel.fadeLength = 20.0;
        songLabel.text = mediaItem.title ?? "不明な曲"
        songLabel.labelSpacing = 50;
        songLabel.pauseInterval = 3;
        songLabel.scrollSpeed = 50.0;
        songLabel.fadeLength = 20.0;
        
        // アートワーク表示
        if let artwork = mediaItem.artwork {
            let image = artwork.image(at: imageView.bounds.size)
            imageView.image = image
        } else {
            // アートワークがないとき
            imageView.image = nil
            imageView.backgroundColor = .gray
        }
        
    }
    
    
    /// 再生中の曲が変更になったときに呼ばれる
    @objc func nowPlayingItemChanged(notification: NSNotification) {
        player.stop()
        
        if let mediaItem = player.nowPlayingItem {
            updateSongInformationUI(mediaItem: mediaItem)
            //プレイヤーを再生
            player.play()
            
            playpause.setImage(UIImage(named :"pause.png"), for: UIControlState())
            playpause.addTarget(self, action: #selector(Pause(_:)), for: .touchUpInside)
        }
        
    }
    
    /// 再生中の曲が変更になったときに呼ばれる
    @objc func b(notification: NSNotification) {
        
        let playStatus = player.playbackState
        if playStatus == .stopped {
            playpause.setImage(UIImage(named :"play.png"), for: UIControlState())
            playpause.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
        }
        
        if playStatus == .paused {
            playpause.setImage(UIImage(named :"play.png"), for: UIControlState())
            playpause.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
        }
        
        if playStatus == .playing {
            playpause.setImage(UIImage(named :"pause.png"), for: UIControlState())
            playpause.addTarget(self, action: #selector(Pause(_:)), for: .touchUpInside)
        }
    }
    
    
    
    deinit {
        // 再生中アイテム変更に対する監視をはずす
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        notificationCenter.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        // ミュージックプレーヤー通知の無効化
        player.endGeneratingPlaybackNotifications()
    }



}


extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}


