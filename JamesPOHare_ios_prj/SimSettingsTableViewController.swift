//
//  SimSettingsTableViewController.swift
//  jamesPOHare_ios_prj_1
//
//  Created by James P OHare on 4/23/20.
//  Copyright © 2020 Access Unlimited. All rights reserved.
//

import UIKit

class SimSettingsTableViewController: UITableViewController, DarkModeChgDelegate {

    override func viewWillAppear(_ animated: Bool) {
        darkModeChg(darkMode: settings.darkMode)
    }
    override func viewDidAppear(_ animated: Bool) {
        darkModeChg(darkMode: settings.darkMode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headingRef.text = String(settings.simHeading)
        hdgAmplRef.text = String(settings.simHdgAmpl)
        hdgPeriodRef.text = String(settings.simHdgPeriod)
        
        speedRef.text = String(settings.simSpeed)
        spdAmplRef.text = String(settings.simSpdAmpl)
        spdPeriodRef.text = String(settings.simSpdPeriod)
        
        settings.darkModeChgDelegate = self
        darkModeChg(darkMode: settings.darkMode)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBOutlet weak var tblView: UITableView!
    func darkModeChg(darkMode: Bool) {
        print("Sim settings darkMode: \(darkMode)")
        if !darkMode {
            self.view.backgroundColor = UIColor.white
            //self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            for cell in tblView.visibleCells { // walk the table cells
                cell.backgroundColor = UIColor.white
                if cell.contentView.subviews.count > 0 {
                    for subview in cell.contentView.subviews { // walk the elements in the cell
                        if let cellLbl = subview as? UILabel {
                            cellLbl.textColor = UIColor.black
                            print(String(cellLbl.text ?? "N/A"))
                        }
                    }
                }
            }
        } else {
            self.view.backgroundColor = UIColor.black
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            //print("Visible cells: \(tblView.visibleCells.count)")
            for cell in tblView.visibleCells { // walk the table cells
                 cell.backgroundColor = UIColor.black
                 //print("subview count: \(cell.contentView.subviews.count)")
                 if cell.contentView.subviews.count > 0 {
                     for subview in cell.contentView.subviews { // walk the elements in the cell
                         if let cellLbl = subview as? UILabel {
                             cellLbl.textColor = UIColor.white
                             print(String(cellLbl.text ?? "N/A"))
                         }
                     }
                 }
             }
        }
    }
    
    @IBOutlet weak var headingRef: UITextField!
    @IBAction func heading(_ sender: Any) {
        
        print("Sim heading: \(headingRef.text ??  "error")")
        settings.simHeading = Float(headingRef.text!) ?? 359.0
    }
    
    @IBOutlet weak var hdgAmplRef: UITextField!
    @IBAction func hdgAmpl(_ sender: Any) {
        print("Sim hdgAmpl: \(hdgAmplRef.text ??  "error")")
        settings.simHdgAmpl = Float(hdgAmplRef.text!) ?? 25
    }
    
    @IBOutlet weak var hdgPeriodRef: UITextField!
    @IBAction func hdgPeriod(_ sender: Any) {
        print("Sim hdgPeriod: \(hdgPeriodRef.text ??  "error")")
        settings.simHdgPeriod = Float(hdgPeriodRef.text!) ?? 20
    }
    
    @IBOutlet weak var speedRef: UITextField!
    @IBAction func speed(_ sender: Any) {
        print("Sim speed: \(speedRef.text ??  "error")")
        settings.simSpeed = Float(speedRef.text!) ?? 10.0
    }
    
    @IBOutlet weak var spdAmplRef: UITextField!
    @IBAction func spdAmpl(_ sender: Any) {
        print("Sim spdAmpl: \(spdAmplRef.text ??  "error")")
        settings.simSpdAmpl = Float(spdAmplRef.text!) ?? 2.0
    }
    
    @IBOutlet weak var spdPeriodRef: UITextField!
    @IBAction func spdPeriod(_ sender: Any) {
        print("Sim spdPeriod: \(spdPeriodRef.text ??  "error")")
        settings.simSpdPeriod = Float(spdPeriodRef.text!) ?? 15
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
