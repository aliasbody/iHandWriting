//
//  VC_Main.swift
//  iHandwriting
//
//  Created by Luis Da Costa on 15/06/16.
//  Copyright © 2016 Luis Da Costa. All rights reserved.
//

import UIKit
import Alamofire

class VC_Main: UIViewController {

    // Stores the image returned by the API
    private var resultImage = UIImage()
    
    // Stores the CatalogList to be used by Catalog the PickerView
    private var itemCatalogList = NSArray()
    private var itemCatalogImage = [UIImage]()

    // Stores all the Parameters which will be sent to the API
    private var arrStrParams = [
        "handwriting_id"        : "",
        "text"                  : "",
        "handwriting_size"      : "20px",
        "handwriting_color"     : "",
        "width"                 : "",
        "height"                : "",
        "line_spacing"          : "1.5",
        "line_spacing_variance" : "0.0",
        "word_spacing_variance" : "0.0",
        "random_seed"           : "-1",
    ]
    
    // Stores all the Presset texts to be used by the Presset PickerView
    private var arrStrPresset = [
        "The quick brown fox"   : "The quick brown fox jumps over the lazy dog.",

        "Thank you"             : "Dear Lauren and Steve, \n Thank you so much for the thoughtful wedding gift. We were looking at crystal wine glasses just the other week. Hope you have a good trip with the family and hope to see you when you get back! \n All the best, \n Allison and Jeremy",

        "Promotion"             : "Dear Valerie, \n Your credit record qualifies you to receive a Star Platinum Card, which offers you no annual fee and a low interest rate of 10%. Just fill out the acceptance form attached to confirm your $2,000 line of credit and we will mail you your Star Platinum Card. \n If you have any questions, don't hesitate to contact us at 1-800-555-3333",
        
        "Kafka"                 : "As Gregor Samsa awoke one morning from uneasy dreams he found himself transformed in his bed into a gigantic insect. He was lying on his hard, as it were armor-plated, back and when he lifted his head a little he could see his dome-like brown belly divided into stiff arched segments on top of which the bed quilt could hardly keep in position and was about to slide off completely. His numerous legs, which were pitifully thin compared to the rest of his bulk, waved helplessly before his eyes.",
        
        "Poe"                   : "Once upon a midnight dreary, as I pondered weak and weary, \n Over many a quaint and curious volume of forgotten lore \n While I nodded, nearly napping, suddenly there came a tapping, \n As of someone gently rapping, rapping at my chamber door.",
        
        "Texting"               : "Have plans for this weekend? \n Not sure yet. What were you thinking? \n My band is playing @ The Bell House on Friday. Only $5, come by! \n Sounds good! What's the address? \n 149 7th Street \n Brooklyn, NY 11215"
    ]
    
    // Stores a set of Colors to be used by the Palette CollectionView
    let arrColorPalette : [UIColor] = [
        UIColor.blackColor(),
        UIColor.darkGrayColor(),
        UIColor.grayColor(),
        UIColor.lightGrayColor(),
        UIColor.brownColor(),
        UIColor.blueColor(),
        UIColor.cyanColor(),
        UIColor.greenColor(),
        UIColor.magentaColor(),
        UIColor.orangeColor(),
        UIColor.purpleColor(),
        UIColor.redColor()
    ]
    
    // Catalog and Presset PickerViews Outlet
    @IBOutlet weak var pickerCatalog: UIPickerView!
    @IBOutlet weak var pickerPresset: UIPickerView!
    
    // Catalog, Presset and User's Text Outlet
    @IBOutlet weak var txtCatalog   : UITextField!
    @IBOutlet weak var txtPresset   : UITextField!
    @IBOutlet weak var txtViewText  : UITextView!

    // Toolbar outlet used by the pickerViews (for the Done Button)
    @IBOutlet weak var toolBarPicker: UIToolbar!

    // Segmented Control Outlet used to display and select the Font Sizes
    @IBOutlet weak var segmentedFontSize: UISegmentedControl!
    
    /*
     Called before the view appears (when it is about to appear)
     
     Defines the layer design (border Color, Width and Radius) of the User's Text View
     based on the Catalog's TextField
     **/
    override func viewWillAppear(animated: Bool) {
        self.txtViewText.layer.borderColor   = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        self.txtViewText.layer.borderWidth   = 0.5
        self.txtViewText.layer.cornerRadius  = 5
        self.txtViewText.layer.masksToBounds = true
    }
    
    /*
     Called when the view is loaded
     
     Makes the initial request to the API in order to get the catalog
     Defines and Sets a Params Width (for the final image) based on the User's Device Screen Width
     Defines and Sets a Params Height as auto
     **/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make a request to the API in order to list the catalog
        self.apiRequestCatalog()
        
        // Defines the width (actual screen width) and height (auto) to present the rendered handwrited image
        self.arrStrParams["width" ] = "\(UIScreen.mainScreen().bounds.width)px"
        self.arrStrParams["height"] = "auto"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     IBAction called when the Done button on the ToolBar (from any pickerView) is tapped.
     
     When tapped, it will mark the visibility of the toolBarPicker, the pickerCatalog
     and the pickerPresset as HIDDEN (true)

     - Parameters:
        - sender: Receives the UIBarButtonItem tapped
     
     */
    @IBAction func btnBarPicker_Action(sender: UIBarButtonItem) {
        self.toolBarPicker.hidden = true
        self.pickerCatalog.hidden = true
        self.pickerPresset.hidden = true
    }
    
    /**
     IBAction called when the Done button on the topBar is tapped
     
     When tapped, it will check if the user's text field is empty, if yes then it will
     display a simple 'OK' Alert asking the user to correct that. Otherwise it will simply
     load the text into the Params list and call the apiRequestImage() function.
     
     - Parameters:
        - sender: Receives the UIBarButtonItem tapped
     */
    
    @IBAction func btnTopBarDone_Action(sender: UIBarButtonItem) {
        if (self.txtViewText.text.isEmpty) {
            self.displaySimpleOKAlert("Impossible to continue", message: "In order to finish the request, you need to provide a text.")
        } else {
            arrStrParams["text"] = self.txtViewText.text
            self.apiRequestImage()
        }
    }
    
    /**
     IBAction called when the user changed the value of the SegmentedControl for the Size of the Font
     
     When selected it will simply compare the actual place of the selectedSegmentedIndex and load into
     the Params list the selected size. The available sizes are:
     - SMALL    : 12px
     - MEDIUM   : 20px
     - LARGE    : 32px
     - XL       : 40px
     
     - Parameters:
        - sender: Receives the UISegmentedControl which contains the tapped value
     */
    @IBAction func segmentedFontSize_onValueChanged(sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
            case 0: // SMALL
                self.arrStrParams["handwriting_size"] = "12px"
                break
            case 1: // MEDIUM
                self.arrStrParams["handwriting_size"] = "20px"
                break
            case 2: // LARGE
                self.arrStrParams["handwriting_size"] = "32px"
                break
            case 3: // XL
                self.arrStrParams["handwriting_size"] = "40px"
                break
            default:
                break
        }
    }
    

    /**
     Function used to request the iHandWriting API for the final, handwrited, image based on the informations sent.
     
     Before the request is made, a presentViewControll on Void is called to present the LoadingAlert, this will show
     the loadingAlert until a dismiss (success or error) is called.
     
     The request is made thanks to the Alamofire Library, by making:
     - Request:
        - Type          : GET
        - URL           : <iHandWriting_URL>
        - Parameters    : <Previously_Stored_Params>
     - Validation :
        - Status Codes between 200 and 299 (returns an error if any other status code is returned)
     - Response:
        - Request   : Stores the request made
        - Response  : Stores the server response
        - Data      : Stores the returned data (if everything went right then it will be an UIImage)
        - Error     : (Thanks to Validation) - Stores any error beyond the status code = 200...<299 scope
     
     If the data received is an image then stops the loadingAlert, returns the image and performs a segue to
     the VC_ImageView ViewController.
     
     If an error is catched then stops the loadingAlert and show a simply 'OK' alert with the error code and message.
     */
    private func apiRequestImage() {
        self.presentViewController(UIAlertController.loadingAlert(), animated: true) { () -> Void in
            Alamofire.request(.GET, ihand_urlAPI, parameters: self.arrStrParams)
                .authenticate(user: ihand_key, password: ihand_secret)
                .validate()
                .response { (request, response, data, error) in
                    if let image = UIImage(data: data!, scale: 1) {
                        self.dismissViewControllerAnimated(true, completion: {
                            self.resultImage = image
                            self.performSegueWithIdentifier("segueImageView", sender: self)
                        })
                    }
                    
                    if (error != nil) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.displaySimpleOKAlert("Error: \(error!.code)", message: error!.localizedDescription)
                    }
                }
        }
    }

    /**
     Function used to request the iHandWriting API for the handwriting catalog list.
     
     Before the request is made, a presentViewControll on Void is called to present the LoadingAlert, this will show
     the loadingAlert until a dismiss (success or error) is called.
     
     The request is made thanks to the Alamofire Library, by making:
     - Request:
        - Type          : GET
        - URL           : <iHandWriting_URL>
     - ResponseJSON:
        - Response  : Stores the server response in a JSON format
     
     If the 'response.result' returns SUCCESS then stops the loadingAlert, gets an NSArray from the result and
     load the returned results into the pickerCatalog (via the itemCatalogList private NSArray)
     
     If the 'response.result' returns FAILURE then stops the loadingAlert and show a simply 'OK' alert with the error code and message.
     */
    private func apiRequestCatalog() {
        self.presentViewController(UIAlertController.loadingAlert(), animated: true) { () -> Void in
            Alamofire.request(.GET, ihand_urlCatalog)
                .authenticate(user: ihand_key, password: ihand_secret)
                .responseJSON { response in
                    switch (response.result) {
                        case .Success:
                            self.dismissViewControllerAnimated(true, completion: {
                                if let arrCatalog = response.result.value as? NSArray {
                                    self.itemCatalogList = arrCatalog.orderByAlpha("title", ascending: true)
                                    
                                    for (index, element) in arrCatalog.orderByAlpha("title", ascending: true).enumerate() {
                                        // Alocate the space with an empty UIImage
                                        self.itemCatalogImage.insert(UIImage(), atIndex: index)
                                        
                                        // Custom Params
                                        let catalogImageParams = [
                                            "handwriting_id"        : "\(element["id"] as! String)",
                                            "text"                  : "\(element["title"] as! String)",
                                            "handwriting_size"      : "40px",
                                            "width"                 : "400px",
                                            "height"                : "auto"]
                                        
                                        // Download the final image into that same space
                                        Alamofire.request(.GET, ihand_urlAPI, parameters: catalogImageParams)
                                            .authenticate(user: ihand_key, password: ihand_secret)
                                            .validate()
                                            .response { (request, response, data, error) in
                                                if let image = UIImage(data: data!, scale: 1) {
                                                    self.itemCatalogImage[index] = image
                                                }
                                        }
                                    }
                                    
                                    // Reload All Components
                                    self.pickerCatalog.reloadAllComponents()
                                }
                            })
                            break
                        case .Failure(let error):
                            self.dismissViewControllerAnimated(true, completion: nil)
                            self.displaySimpleOKAlert("Error: \(error.code)", message: error.localizedDescription)
                            break
                    }
            }
        }
    }
    
    /**
     UIViewController function overrided in order to handle the segue to the VC_ImageView by defining the received
     image to the right variable (inside that same ViewController Class) before going ahead with the segue.
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueImageView") {
            if let vcViewImage : VC_ViewImage = segue.destinationViewController as? VC_ViewImage {
                vcViewImage.resultImage = self.resultImage
            }
        }
    }
}

extension VC_Main: UIPickerViewDelegate, UIPickerViewDataSource {
    /**
     Function to simply define the number of 'columns' to be displayed on the PickerView
     
     Will always return 1 because we only need one column per PickerView
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     Function to simply defines the number of 'rows' to be displayed on the PickerView
     
     If the selected pickerView is the Catalog then returns the Count of the Array of Catalogs.
     If the selected pickerView is the Presset then returns the Count of the Array of Pressets.
     */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == self.pickerCatalog) {
            return self.itemCatalogList.count
        } else if (pickerView == self.pickerPresset) {
            return self.arrStrPresset.count + 1
        } else {
            return 0
        }
    }
    
    /**
     Function to simply display a value for the returned index(row) of a pickerView (String Format).
     
     If the selected pickerView is the Catalog then returns, per row, the title of same Array index of Catalogs.
     If the selected pickerView is the Presset then returns, per row, the title of same Array index of Pressets.
     */
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        if (pickerView == self.pickerCatalog) {
            if (self.itemCatalogImage[row].CGImage == nil) {
                let pickerLabel = UILabel()
                
                if let strTitle = self.itemCatalogList[row]["title"] as? String {
                    pickerLabel.text = strTitle
                }
                
                return pickerLabel
            } else {
                let pickerImage = UIImageView()
                pickerImage.image = self.itemCatalogImage[row]
                
                return pickerImage
            }
            
        } else if (pickerView == self.pickerPresset) {
            let pickerLabel = UILabel()

            if (row == 0) {
                self.txtPresset.text    = ""
                pickerLabel.text        = ""
            } else if (row >= 1) {
                self.txtPresset.text    = Array(self.arrStrPresset.keys)[row-1]
                pickerLabel.text        = Array(self.arrStrPresset.keys)[row-1]
            }
            
            return pickerLabel
        } else {
            return UIView()
        }
    }
    
    /**
     Function to simply trigger an action when a row is selected in the PickerView
     
     If the selected pickerView is the Catalog then returns, on the Catalog TextField, the title of same Array index of Catalogs.
     If the selected pickerView is the Presset then returns, on the Presset TextField, the title of same Array index of Pressets.
     */
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == self.pickerCatalog) {
            
            if let strTitle = self.itemCatalogList[row]["title"] as? String {
                self.txtCatalog.text = strTitle
            }
                
            if let strID = self.itemCatalogList[row]["id"] as? String {
                self.arrStrParams["handwriting_id"] = strID
            }
            
            // Reload the selected component (in order to make it show the image (if any)
            if ((pickerView.viewForRow(row, forComponent: component) as? UIImageView) != nil) {
                pickerView.reloadComponent(component)
            }
        } else if (pickerView == self.pickerPresset) {
            self.txtPresset.text    = (row > 0 ? Array(self.arrStrPresset.keys)[row-1]                      : "")
            self.txtViewText.text   = (row > 0 ? self.arrStrPresset[Array(self.arrStrPresset.keys)[row-1]]  : "")
        }
    }
}

extension VC_Main: UITextFieldDelegate {
    /**
     Delegate function from the UITextFieldDelegate, is called when a textField is about to be edited.
     
     If the selected textField is asking to become first responder (necessary because of IQKeyboardManager) then handle
     the selection by showing the appropriate picker, otherwise does nothing.
     
     In any case returns false (so that the keyboard won't pear because the Should Begin Editing is canceled)
     
     If the selected textField is Catalog then shows the Catalog PickerView
     If the selected textField is Presset then shows the Presset PickerView
     */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField.isAskingCanBecomeFirstResponder == false) {
            if (textField == self.txtCatalog) {
                self.toolBarPicker.hidden = false
                self.pickerCatalog.hidden = false
            } else {
                self.toolBarPicker.hidden = false
                self.pickerPresset.hidden = false
            }
        }
    
        // Disable any typping on the textfield
        return false
    }
}

extension VC_Main: UICollectionViewDelegate, UICollectionViewDataSource {
    /**
     Function to simply define the numberOfItems in a UICollectionView section
     
     - Returns:
        - Count of the Color Palette Array
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrColorPalette.count
    }
    
    /**
     Function to simply creates or reuses a custom cell (CellColorBubble) for each item on the CollectionView, on visible cells.
     Hides the CheckMark image if it is not the first selected item.
     Sets the backgroundColor based on colorPalete Array (easier to know the color of the selected cell afterwards)
     
     - Returns:
        - New or Reused Cell (based on if it exists or no)
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : CellColorBubble = collectionView.dequeueReusableCellWithReuseIdentifier("CellColorBubble", forIndexPath: indexPath) as! CellColorBubble
        
        cell.imgCheckMark.hidden    = (collectionView.indexPathsForSelectedItems()?.first != indexPath)
        cell.backgroundColor        = self.arrColorPalette[indexPath.row]

        return cell
    }
    
    /**
     Function triggered then a cell inside the CollectionView is Selected (for visible cells)
     If the cell is visible then shows the checkMark and sets the handwriting color to the selected one
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell : CellColorBubble = collectionView.cellForItemAtIndexPath(indexPath) as? CellColorBubble {
            cell.imgCheckMark.hidden = false
            self.arrStrParams["handwriting_color"] = cell.backgroundColor?.toHexString()
        }
    }
    
    /**
     Function triggered then a cell inside the CollectionView is Deselected (for visible cells)
     If the cell deselected (after another cell has been selected) is visible then hides the checkMark
     */
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell : CellColorBubble = collectionView.cellForItemAtIndexPath(indexPath) as? CellColorBubble {
            cell.imgCheckMark.hidden = true
        }
    }
}

// Custom CollectionViewCell class to be used on the Color Palette CollectionView
class CellColorBubble: UICollectionViewCell {
    // [Outlet Objects] - UIImageView
    @IBOutlet weak var imgCheckMark: UIImageView!
    
    /**
     Function triggered when a cell is about to be reused
     This is called in order to mark them as NON Selected and to hide the CheckMark, which helps in case a scroll
     is made from a selected cell in order to avoid multiple (wrongly) selected cells
     */
    override func prepareForReuse() {
        self.selected       = false
        imgCheckMark.hidden = true
    }
}
