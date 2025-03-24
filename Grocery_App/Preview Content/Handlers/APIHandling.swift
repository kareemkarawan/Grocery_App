//
//  APIHandling.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 13/03/2025.
//

import Foundation

class APIHandling: ObservableObject {
    var BASE_URL: String = "https://world.openfoodfacts.org/"
    
    func fetchProductsByStoreAndCategory(store: String, category: String, completion: @escaping ([Item]?) -> Void) {
        let urlString = "https://world.openfoodfacts.org/api/v2/search?stores=\(store)"
        print("Fetching from URL: \(urlString)")
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching store products: ", error?.localizedDescription ?? "Unkown error")
                completion(nil)
                return
            }
            do {
                let jsonResponse = try JSONDecoder().decode([String: [Item]].self, from: data)
                let allItems = jsonResponse["products"]
                let filteredItems = allItems?.filter { i in
                    i.category?.lowercased().contains(category.lowercased()) ?? false
                }
                completion(filteredItems)
                
            } catch {
                print("Error decoding json: ", error)
                completion(nil)
            }
        }.resume()
    }
    
    func fetchCategoriesForStore(store: String, completion: @escaping ([String]) -> Void) {
        let urlString = "https://world.openfoodfacts.org/api/v2/search?stores=\(store)"
        print("Fetching from URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion ([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching store products: ", error?.localizedDescription ?? "Unkown error")
                completion([])
                return
            }
            do {
                let jsonResponse = try JSONDecoder().decode([String: [Item]].self, from: data)
                let items = jsonResponse["products"] ?? []
                let categoriesSet = Set(items.compactMap{ $0.category })
                let categoriesList = Array(categoriesSet).sorted()
                
                completion(categoriesList)
            } catch {
                print("Error decoding json: \(error)")
                completion([])
            }
        }.resume()
    }
}
