import UIKit

func groupedStringWithString(var aString: NSString, aGroupSeparater: NSArray, maxLength: Int, numberGrouping: NSArray) -> String {
    
    guard aString.length != 0 else {
        return ""
    }
    
    if aString.length > maxLength {
        aString = aString.substringWithRange(NSMakeRange(0, maxLength))
    }
    
    let mutableString = NSMutableString(capacity: aString.length + numberGrouping.count - 1)
    var location = 0
    
    for var i = 0; i < numberGrouping.count; i++ {
        let digitCountNumber = numberGrouping[i] as! NSNumber
        let digitCount = digitCountNumber.integerValue
        
        if digitCount == 0 && i == 0 {
            mutableString.appendString(aGroupSeparater[i] as! String)
        } else {
            var substringRange = NSMakeRange(location, min(digitCount, aString.length - location))
            mutableString.appendString(aString.substringWithRange(substringRange))
            location += substringRange.length
            
            if substringRange.length < digitCount {
                break
            }
            
            if i < numberGrouping.count - 1 {
                substringRange = NSMakeRange(location, min(digitCount, aString.length - location))
                if aString.substringWithRange(substringRange).characters.count > 0 {
                    mutableString.appendString(aGroupSeparater[i] as! String)
                }
            }
        }
    }
    
    return "\(mutableString)"
}

var creditCard = groupedStringWithString("4984069217430278", aGroupSeparater: [" "," "," "], maxLength: 16, numberGrouping: [4,4,4,4])
var cep = groupedStringWithString("04256177", aGroupSeparater: ["-"], maxLength: 8, numberGrouping: [5,3])
var cpf = groupedStringWithString("35297173809", aGroupSeparater: [".",".","-"], maxLength: 11, numberGrouping: [3,3,3,2])
var phone = groupedStringWithString("11962998496", aGroupSeparater: ["(",")","-"], maxLength: 11, numberGrouping: [0,2,5,4])
