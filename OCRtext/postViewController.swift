//
//  postViewController.swift
//  OCRtext
//
//  Created by 平良悠貴 on 2019/10/19.
//  Copyright © 2019 平良悠貴. All rights reserved.
//


import UIKit
import Vision
import VisionKit

var str = [""]
var pattern = ""
let patterns = ".*"+pattern
//let pattern = "^.*(\\d{3}-\\d{4}).*$"
var arrayMatch  = [1]
var finalResult = [""]
var finalResults = ""

class postViewController: UIViewController {

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

        let p = ".*(〒\\d{3}-\\d{4}).*(〒\\d{3}-\\d{4}).*"
        let str = "ORONTCADUAWANM0NNN W*D*10R1BK) B13R0)* CHRNUERTESTS**N coM reRan.REF OREDDaDEUCT. NE AHERAtto cH tEN Ta uTeRaU.&E. 10A13ENNTRHNOST ONDANES:KAI-ILR4ROWEDUT.〒234-4421 XFOZ*-RYNEIBEHE. MIR090-1737-0747ANTCARDUWNDDURTIMEat* a TiNtIN bUSTL A 319/2123.:50NBRnaT T MUl*S.〒242-0032.h-.I I-*sN..."
        print(str.capture(pattern: p, group: [1, 2]))
        let a = str.capture(pattern: p, group: [1, 2])
        print(a[0])
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

extension postViewController: VNDocumentCameraViewControllerDelegate {

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
            self.matchPattern = "(\\d{3}-\\d{4})"
            let matchCount = self.getMatchCount(targetString: self.targetString, pattern: self.matchPattern)
            print(matchCount)

            var counter = 1
            while counter <= matchCount{
                pattern = self.matchPattern + ".*" + pattern
                counter += 1
            }


            //MARK:DispatchQueue
            DispatchQueue.main.async(execute: {
                //                str = self.resultingText.components(separatedBy: "\n")

                print(patterns)

                if matchCount == 0{
                    self.textView.text = ""
                    print("arrayMatchは0だよ!!")
                }else if matchCount == 1{
                    arrayMatch = [1]
                    print("arrayMatchは",arrayMatch)
                }else{
                    arrayMatch = []
                    for i in 1...matchCount{
                        arrayMatch.append(i)
                        print("arrayMatchは",arrayMatch)
                    }
                }
                print(arrayMatch)
                print("これ",self.resultingText)
//                print(self.resultingText.capture(pattern: patterns, group: arrayMatch))
                finalResult = self.resultingText.capture(pattern: patterns, group: arrayMatch)
                print("finalResultは",finalResult)

                if matchCount == 0{
                    finalResults = ""
                }else{
                    for count in 0..<matchCount{
                        finalResults = finalResult[count] + "\n" + finalResults
                        print(finalResults)
                    }
                }

                self.textView.text = finalResults
                self.activityIndicator.isHidden = true
            })
        }

    }
}
