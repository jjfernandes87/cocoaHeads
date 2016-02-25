import UIKit

var currencyFormatter: NSNumberFormatter?

func bootstrapNumberFormatters() {
    if currencyFormatter == nil {
        currencyFormatter = NSNumberFormatter()
        currencyFormatter?.numberStyle = .CurrencyStyle
        currencyFormatter?.locale = NSLocale(localeIdentifier: "pt_BR")
        currencyFormatter?.generatesDecimalNumbers = false
        currencyFormatter?.maximumFractionDigits = 0
    }
}

func changeCharactersInRangeFormatter(range: NSRange, string: String, currentString: NSString) -> String {
    
    if currencyFormatter == nil {
        bootstrapNumberFormatters()
    }
    
    objc_sync_enter(currencyFormatter)
    
    let newText = currentString.stringByReplacingCharactersInRange(range, withString: string)
        .stringByReplacingOccurrencesOfString(currencyFormatter!.currencySymbol!, withString: string)
        .stringByReplacingOccurrencesOfString(currencyFormatter!.groupingSeparator!, withString: string)
        .stringByReplacingOccurrencesOfString(currencyFormatter!.decimalSeparator!, withString: string)
    
    objc_sync_exit(currencyFormatter)
    
    return newText
}

func doubleToCurrencyStringFormatter(number: Double) -> String {
    return doubleToCurrencyStringFormatterAndMaximumFractionDigits(number, maximumFractionDigits: 0)
}

func doubleToCurrencyStringFormatterAndMaximumFractionDigits(number: Double, maximumFractionDigits: Int) -> String {
    
    if currencyFormatter == nil {
        bootstrapNumberFormatters()
    }
    
    objc_sync_enter(currencyFormatter)
    
    currencyFormatter!.generatesDecimalNumbers = maximumFractionDigits > 0
    currencyFormatter!.maximumFractionDigits = maximumFractionDigits
    currencyFormatter!.minimumFractionDigits = maximumFractionDigits
    
    objc_sync_exit(currencyFormatter)
    
    return currencyFormatter!.stringFromNumber(NSNumber(double: number))!
}

func currencyStringToDecimalNumberFormatter(currencyString: String) -> NSDecimalNumber {
    
    if currencyFormatter == nil {
        bootstrapNumberFormatters()
    }
    
    
    return currencyFormatter?.numberFromString(currencyString) as! NSDecimalNumber
}

var value = doubleToCurrencyStringFormatter(1000)
var valueWith2Digits = doubleToCurrencyStringFormatterAndMaximumFractionDigits(1000.12, maximumFractionDigits: 2)
var number = currencyStringToDecimalNumberFormatter("R$1200")
