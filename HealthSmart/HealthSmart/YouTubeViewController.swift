//
//  YouTubeViewController.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/28/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit

class YouTubeViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YTPlayerView!
    var recipeName : String!
    var videoId : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        getYouTubeVideos()
        youtubePlayer.load(withVideoId: videoId)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ingredients.png")!).withAlphaComponent(0.4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getYouTubeVideos(){
        print(recipeName!)
        let recipe = recipeName.replacingOccurrences(of: "[^a-zA-Z0-9]+", with: "",options:.regularExpression)
        print(recipe)
        var request = URLRequest(url: NSURL(string: "https://www.googleapis.com/youtube/v3/search?q=\(recipe)&maxResults=25&part=snippet&key=AIzaSyBujf95a0exvveY7ptQ89P89x_W1f16iy4")! as URL)
        print(request)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do{
            // Perform the request
            var response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            // Convert the data to JSON
            let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            
            print(jsonSerialized)
            if let json = jsonSerialized {
                let items = json["items"] as? [[String:Any]]
                for item in items! {
                   
                    var id = item["id"] as? [String : Any]
                    videoId = (id!["videoId"] as? String)!
                    break
                }
            }
            
            
        }catch{
            print("exception while loading recipes")
        }
    }
    
    
    @IBAction func closeBtn(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
