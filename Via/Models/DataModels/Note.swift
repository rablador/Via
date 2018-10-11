import UIKit
import ObjectMapper

struct Note: ImmutableMappable {

    let severity: VasttrafikEnum.NoteSeverity
    let text: String

    init(map: Map) throws {
        severity = try map.value("severity", using: VasttrafikTransform.noteSeverity())
        text = try map.value("$")
    }

    mutating func mapping(map: Map) {}
}

extension Note: VasttrafikArrayMappable {

    static func jsonToArray(_ json: JSON) -> [Note] {
        var notes = [Note]()

        if let note = json["Note"] as? [JSON] {
            note.forEach { json in
                do { notes.append(try Mapper<Note>().map(JSON: json)) } catch {}
            }
        } else if let note = json["Note"] as? JSON {
            do { notes.append(try Mapper<Note>().map(JSON: note)) } catch {}
        }

        return notes.filterDuplicatesOnAttribute { $0.text == $1.text }
    }
}
