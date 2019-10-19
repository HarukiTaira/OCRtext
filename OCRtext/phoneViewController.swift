//
//  phoneViewController.swift
//  OCRtext
//
//  Created by 平良悠貴 on 2019/10/19.
//  Copyright © 2019 平良悠貴. All rights reserved.
//

import UIKit
import Vision
import VisionKit

var phone_str = [""]
var phone_pattern = ""
let phone_patterns = ".*"+phone_pattern
//let pattern = "^.*(\\d{3}-\\d{4}).*$"
var phone_arrayMatch  = [1]
var phone_finalResult = [""]
var phone_finalResults = ""

class phoneViewController: UIViewController {
    
    @IBOutlet var imagePick:UIImageView!
    @IBOutlet var scanButton:UIButton!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // Vision requests to be performed on each page of the scanned document.
    private var requests = [VNRequest]()
    // Dispatch queue to perform Vision requests.
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var resultingText = ""
    var targetString = ""
    var matchPattern = ""
    
    //MARK:Setup関数
    
    // Setup Vision request as the request can be reused
    private func setupVision() {
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // Concatenate the recognised text from all the observations.
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                //                self.resultingText += candidate.string + "\n"
                self.resultingText += candidate.string
                
            }
        }
        // specify the recognition level
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }
    
    //MARK:override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVision()
    }
    //MARK:正規表現の一致回数
    func getMatchCount(targetString: String, pattern: String) -> Int {
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let targetStringRange = NSRange(location: 0, length: (targetString as NSString).length)
            
            return regex.numberOfMatches(in: targetString, options: [], range: targetStringRange)
            
        } catch {
            print("error: getMatchCount")
        }
        return 0
    }
    //MARK:IBAction
    @IBAction func scanReceipts(_ sender: UIControl?) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
}

// MARK: VNDocumentCameraViewControllerDelegate

extension phoneViewController: VNDocumentCameraViewControllerDelegate {
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Clear any existing text.
        textView?.text = ""
        // dismiss the document camera
        controller.dismiss(animated: true)
        
        activityIndicator.isHidden = false
        
        textRecognitionWorkQueue.async {
            self.resultingText = ""
            
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                self.imagePick.image = image
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    
                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error)
                    }
                }
                self.resultingText += "\n\n"
            }
            self.targetString = self.resultingText
            self.matchPattern = "(0\\d{1,4}-\\d{1,4}-\\d{4}|0[89]0\\d{4}-?\\d{4})"
            let matchCount = self.getMatchCount(targetString: self.targetString, pattern: self.matchPattern)
            print(matchCount)

            var counter = 1
            while counter <= matchCount{
                phone_pattern = self.matchPattern + ".*" + phone_pattern
                counter += 1
            }
            
            
            //MARK:DispatchQueue
            DispatchQueue.main.async(execute: {
                //                str = self.resultingText.components(separatedBy: "\n")
              
                print(phone_patterns)
                
                if matchCount == 0{
                    self.textView.text = ""
                    print("arrayMatchは0だよ!!")
                }else if matchCount == 1{
                    phone_arrayMatch = [1]
                    print("arrayMatchは",phone_arrayMatch)
                }else{
                    phone_arrayMatch = []
                    for i in 1...matchCount{
                        phone_arrayMatch.append(i)
                        print("arrayMatchは",phone_arrayMatch)
                    }
                }
                print(phone_arrayMatch)
                print("これ",self.resultingText)
//                print(self.resultingText.capture(pattern: phone_patterns, group: phone_arrayMatch))
                phone_finalResult = self.resultingText.capture(pattern: phone_patterns, group: phone_arrayMatch)
                print("finalResultは",phone_finalResult)
                
                if matchCount == 0{
                    phone_finalResults = ""
                }else{
                    for count in 0..<matchCount{
                        phone_finalResults = phone_finalResult[count] + "\n" + phone_finalResults
                        print(phone_finalResults)
                    }
                }
                
                self.textView.text = phone_finalResults
                self.activityIndicator.isHidden = true
            })
        }
        
    }
}

//MARK: String

extension String {
    
    /// 正規表現でキャプチャした文字列を抽出する
    ///
    /// - Parameters:
    ///   - pattern: 正規表現
    ///   - group: 抽出するグループ番号(>=1)
    /// - Returns: 抽出した文字列
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
    /// 正規表現でキャプチャした文字列を抽出する
    ///
    /// - Parameters:
    ///   - pattern: 正規表現
    ///   - group: 抽出するグループ番号(>=1)の配列
    /// - Returns: 抽出した文字列の配列
    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }
        
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
