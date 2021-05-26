import UIKit

struct Person: Codable {
  let name: String
  let age: Int
  let isDeveloper: Bool
}

protocol ParseChain {
  var next: ParseChain? { get set }
  var chainLinkName: String { get }
  
  func parse(from name: String) -> [Person]
  func getNext(name: String) -> [Person]
}

extension ParseChain {
  func getNext(name: String) -> [Person] {
    print("\(name) пропущено \(chainLinkName)")
    
    guard let next = next else {
      return [Person]()
    }
    return next.parse(from: name)
  }
}

class chainLink1: ParseChain {
  struct Response: Codable {
    var data: [Person]
  }
  
  var next: ParseChain?
  let chainLinkName = #function
  
  func parse(from name: String) -> [Person] {
    if let response: Response = response(from: data(from: name)) {
      print("\(name) разобрано \(chainLinkName)")
      return response.data
    }
    return getNext(name: name)
  }
}

class chainLink2: ParseChain {
  struct Response: Codable {
    var result: [Person]
  }
  
  var next: ParseChain?
  let chainLinkName = #function

  func parse(from name: String) -> [Person] {
    if let response: Response = response(from: data(from: name)) {
      print("\(name) разобрано \(chainLinkName)")
      return response.result
    }
    return getNext(name: name)
  }
}

class chainLink3: ParseChain {
  var next: ParseChain?
  let chainLinkName = #function

  func parse(from name: String) -> [Person] {
    if let response: [Person] = response(from: data(from: name)) {
      print("\(name) разобрано \(chainLinkName)")
      return response
    }
    return getNext(name: name)
  }
}

func parse(from: String) -> [Person] {
  let chain1 = chainLink1()
  let chain2 = chainLink2()
  let chain3 = chainLink3()
  
  chain1.next = chain2
  chain2.next = chain3
  
  return chain1.parse(from: from)
}

func data(from file: String) -> Data {
  let path1 = Bundle.main.path(forResource: file, ofType: "json")!
  let url = URL(fileURLWithPath: path1)
  let data = try! Data(contentsOf: url)
  return data
}

func response<T: Codable>(from data: Data) -> T? {
  let decoder = JSONDecoder()
  let result = try? decoder.decode(T.self, from: data)
  return result
}

let result1 = parse(from: "1")
let result2 = parse(from: "2")
let result3 = parse(from: "3")
