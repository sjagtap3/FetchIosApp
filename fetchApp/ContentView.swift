//
//  ContentView.swift
//  fetchApp
//
//  Created by Shrushti Jagtap on 3/19/24.
//

import SwiftUI

struct Item: Identifiable, Hashable, Decodable {
    let id: Int
    let listId: Int
    let name: String?
}

struct ContentView: View {
  @State private var items: [String: [Item]] = [:]

    func fetchData() async {
      guard let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json") else { return }
      do {
        let (data, _) = try await URLSession.shared.data(from: url)
        // print(String(data: data, encoding: .utf8) ?? "Data could not be printed as UTF-8 string")
        let itemList = try JSONDecoder().decode([Item].self, from: data)
        store(items: itemList)
      } catch {
        print("Error :", error)
      }
    }

    func store(items: [Item]) {
        self.items = Dictionary(grouping: items) { String($0.listId) }
            .mapValues { $0.filter { $0.name != nil && !$0.name!.isEmpty }
                         .sorted { $0.name ?? "" < $1.name ?? "" } }
            .filter { !$0.value.isEmpty }
    }


    var body: some View {
      NavigationView {
        List {
          ForEach(items.keys.sorted(), id: \.self) { listId in
            Section(header: Text(listId)) {
              ForEach(items[listId]!, id: \.self) { item in
                Text(item.name ?? "N/A")
              }
            }
          }
        }
        .navigationTitle("List of Items: ")
        .onAppear {
          Task {
            await fetchData()
          }
        }
      }
    }
}

#Preview {
    ContentView()
}
