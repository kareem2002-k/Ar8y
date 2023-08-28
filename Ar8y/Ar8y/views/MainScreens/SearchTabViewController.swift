//
//  SearchTabViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 28/08/2023.
//

import UIKit

class SearchTabViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchResults: [UserProfiLe] = []


    override func viewDidLoad() {
        super.viewDidLoad()

      
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: "UserShowTableViewCell", bundle: nil), forCellReuseIdentifier: "userDetailsCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60 // Set an estimated row height, this can be any value
        
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userDetailsCell", for: indexPath) as! UserShowTableViewCell
        let user = searchResults[indexPath.row]
        
       
        cell.fullnameLabel.text = user.FullName
        cell.userNameLabel.text = user.Username
        cell.id = user.ID
        
        if user.IsFollowedByAuthUser {
            cell.followButton.setTitle("Unfollow", for: .normal)
        }else {
            cell.followButton.setTitle("Follow", for: .normal)

            
        }
        
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults.removeAll()
            tableView.reloadData()
            return
        }
        
        // Call your SearchController here to perform the search
        if let authToken = TokenManager.shared.getToken(){ // Replace with your actual auth token
            SearchController.shared.Search(authtoken: authToken, query: searchText) { success, users in
                if success, let users = users {
                    self.searchResults = users
                    self.tableView.reloadData()
                } else {
                    // Handle the case when the search fails
                }
            }
        } else{
            print("failed to get token")
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResults.removeAll()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            // Perform the push to the desired view controller here
            // For example:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let singleuser = storyboard.instantiateViewController(withIdentifier: "userProfile") as? SingleUserViewController {
                // Assign data to the receiving variables
                          
                singleuser.id = searchResults[indexPath.row].ID

                
                // Configure the detailViewController if needed
                navigationController?.pushViewController(singleuser, animated: false)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
