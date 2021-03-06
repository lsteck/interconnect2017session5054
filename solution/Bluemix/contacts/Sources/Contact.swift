import Foundation
import SwiftyJSON

struct Contact {
    let id:       Int
    let first:    String
    let last:    String
    let phone:    String
}


extension Contact: Equatable { }

func == (lhs: Contact, rhs: Contact) -> Bool {
    if  lhs.id          == rhs.id,
        lhs.first       == rhs.first,
        lhs.last        == rhs.last,
        lhs.phone       == rhs.phone{
        return true
    }
    
    return false
    
}

extension Contact: JSONConvertible {
    init (json: JSON) throws {
        guard let d = json.dictionary,
            let id = d["id"]?.int,
            let first = d["first"]?.string,
            let last = d["last"]?.string,
            let phone = d["phone"]?.string else {
                throw ContactError.malformedJSON
        }
        self.id = id
        self.first = first
        self.last = last
        self.phone = phone
    }
    var dictionary: [String: Any] {
        
        return ["id": id as Any, "first": first as Any, "last": last as Any, "phone": phone as Any]
        
    }
}

enum ContactError: String, Error { case malformedJSON }


protocol JSONConvertible {
    var dictionary: [String: Any] {get}
    init(json: JSON) throws
}

extension Array where Element : JSONConvertible {
    var dictionary: [[String: Any]] {
        return self.map { $0.dictionary }
    }
}


