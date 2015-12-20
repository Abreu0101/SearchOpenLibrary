//
//  ViewController.swift
//  SearchBookOpenLibrary
//
//  Created by Roberto Abreu on 20/12/15.
//  Copyright © 2015 homeappz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var txtBookISBN: UITextField!
    @IBOutlet var tvResponse: UITextView!
    
    @IBAction func searchBook(sender: AnyObject) {
        self.txtBookISBN.resignFirstResponder()
        getBookByISBN(txtBookISBN.text!)
    }
    
    func getBookByISBN(isbn:String){
        
        let session = NSURLSession.sharedSession()
        
        let urlLiteral = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
        
        let url = NSURL(string: urlLiteral)
        
        if let url = url{
            session.dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let error = error{
                        self.showMessage(error.localizedDescription)
                    }else{
                        if let response = response as? NSHTTPURLResponse{
                            
                            if response.statusCode == 200{
                                let info = String(data: data!, encoding: NSUTF8StringEncoding)
                                self.tvResponse.text = info
                            }else{
                                self.showMessage((error?.localizedDescription)!)
                            }
                        }
                    }
                })
            }.resume()
        }else{
            showMessage("URL mal formada.")
        }
  
    }
    
    func showMessage(message:String){
        
        let alert = UIAlertController(title: "Mensaje", message: message, preferredStyle: .Alert)
        
        let actionAccept = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        
        alert.addAction(actionAccept)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

