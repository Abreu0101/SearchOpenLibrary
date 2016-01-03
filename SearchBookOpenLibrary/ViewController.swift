//
//  ViewController.swift
//  SearchBookOpenLibrary
//
//  Created by Roberto Abreu on 20/12/15.
//  Copyright © 2015 homeappz. All rights reserved.
//

import UIKit

protocol SearchDelegate{
    func bookSearched(book:[String:String])
}

class ViewController: UIViewController {

    @IBOutlet var txtBookISBN: UITextField!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgBook: UIImageView!
    @IBOutlet var lblAuthorNames: UILabel!
    
    var searchDelegate: SearchDelegate!
    
    var bookDetail:[String:String]?
    
    override func viewDidLoad() {
        setupDetailData()
    }
    
    func setupDetailData(){
        
        if let bookDetail = bookDetail{
            
            if let title = bookDetail["title"]{
                self.lblTitle.text = title
            }
            
            if let author = bookDetail["author"]{
                self.lblAuthorNames.text = author
            }
            
            if let thumbnail = bookDetail["thumbnail"]{
                self.showImageBook(thumbnail)
            }
            
            if let isbn = bookDetail["isbn"]{
                self.txtBookISBN.text = isbn
            }
        }
        
    }
    
    @IBAction func searchBook(sender: AnyObject) {
        self.txtBookISBN.resignFirstResponder()
        getBookByISBN(txtBookISBN.text!)
    }
    
    func cleanInterface(){
        self.lblTitle.text = ""
        self.lblAuthorNames.text = ""
        self.imgBook.image = nil
    }
    
    func getBookByISBN(isbn:String){
        
        self.cleanInterface()
        
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
                                do{
                                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
                                    
                                    if let book = json.objectForKey("ISBN:\(isbn)") as? NSDictionary{
                                        
                                        var dataDelegate:[String:String] = Dictionary<String,String>()
                                        
                                        if let title = book.objectForKey("title") as? String{
                                            self.lblTitle.text = title
                                            dataDelegate["title"] = title
                                        }
                                        
                                        if let authors = book.objectForKey("authors") as? Array<NSDictionary>{
                                            var authorResult = ""
                                            for dictAuthor in authors{
                                                if let nameAuthor = dictAuthor.objectForKey("name") as? String{
                                                    authorResult += nameAuthor + "\n"
                                                }
                                            }
                                            self.lblAuthorNames.text = authorResult
                                            dataDelegate["author"] = authorResult
                                        }
                                        
                                        if let covers = book.objectForKey("cover") as? NSDictionary{
                                            if let thumbnailURL = covers.objectForKey("medium") as? String{
                                                self.showImageBook(thumbnailURL)
                                                dataDelegate["thumbnail"] = thumbnailURL
                                            }
                                        }
                                        
                                        dataDelegate["isbn"] = isbn
                                        self.searchDelegate.bookSearched(dataDelegate)
                                    }
                                }catch _ {
                                    self.showMessage("Error to process JSON")
                                }
                               
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
    
    func showImageBook(urlThumbnail:String){
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: urlThumbnail)
        
        session.dataTaskWithURL(url!) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let error = error{
                    self.showMessage(error.localizedDescription)
                }else{
                    if let response = response as? NSHTTPURLResponse{
                        
                        if response.statusCode == 200{
                            self.imgBook.image = UIImage(data: data!)
                        }else{
                            self.showMessage((error?.localizedDescription)!)
                        }
                    }
                }
            })
        }.resume()
    }
    
    func showMessage(message:String){
        
        let alert = UIAlertController(title: "Mensaje", message: message, preferredStyle: .Alert)
        
        let actionAccept = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        
        alert.addAction(actionAccept)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

