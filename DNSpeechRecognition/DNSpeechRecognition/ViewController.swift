//
//  ViewController.swift
//  DNSpeechRecognition
//
//  Created by mainone on 16/11/16.
//  Copyright © 2016年 wjn. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var micButton: UIButton!
    
    private var audioEngine: AVAudioEngine!
    private var speechRecognizer: SFSpeechRecognizer!
    private var speechRequest: SFSpeechAudioBufferRecognitionRequest!
    private var currentSpeechTask: SFSpeechRecognitionTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.audioEngine = AVAudioEngine()
        self.speechRecognizer = SFSpeechRecognizer()
        self.micButton.isEnabled = false;
        SFSpeechRecognizer.requestAuthorization { (status) in
            guard status == .authorized else {// 用户授权判断
                return;
            }
            // 初始化语音处理器的输入模式
            let myFormat = self.audioEngine.inputNode?.outputFormat(forBus: 0)
            self.audioEngine.inputNode?.installTap(onBus: 0, bufferSize: 1024, format: myFormat, block: { (buffer, time) in
                 // 为语音识别请求对象添加一个AudioPCMBuffer，来获取声音数据
                self.speechRequest.append(buffer)
            })
            // 语音处理器准备就绪（会为一些audioEngine启动时所必须的资源开辟内存）
            self.audioEngine.prepare()
        
            self.micButton.isEnabled = true
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func micBtnClick(_ sender: UIButton) {
        if self.currentSpeechTask.state == .running {
            self.micButton.setTitle("开始", for: .normal)
            // 停止语音识别
            self.stopDictating()
        } else {
            self.micButton.setTitle("停止", for: .normal)
            self.contentLabel.text = "等待识别"
            // 开始语音识别
            self.startDictating()
        }
    }
    
    func startDictating() {
        do {
            // 启动声音处理器
            try self.audioEngine.start()
            // 初始化
            self.speechRequest = SFSpeechAudioBufferRecognitionRequest()
            // 使用speechRequest请求进行识别
            self.currentSpeechTask = self.speechRecognizer.recognitionTask(with: self.speechRequest, resultHandler: { (result, error) in
                // 识别结果
                guard result != nil else {
                    return
                }
                self.contentLabel.text = result?.bestTranscription.formattedString;
            })
            
        } catch {
            print("开启失败: \(error)")
        }
        
    }
    
    func stopDictating() {
        self.audioEngine.stop()
        self.speechRequest.endAudio()
    }

}

