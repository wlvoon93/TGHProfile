//
//  UIImage+InvertedColor.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 27/12/2022.
//

import UIKit

extension UIImage {
    func inverseImage(cgResult: Bool) -> UIImage? {
        let coreImage = self.ciImage
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        if cgResult { // I've found that UIImage's that are based on CIImages don't work with a lot of calls properly
            return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
        }
        return UIImage(ciImage: result)
    }
}
