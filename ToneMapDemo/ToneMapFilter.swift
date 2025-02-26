//
//  ToneMapFilter.swift
//  ToneMapDemo
//
//  Created by Jeffrey Blagdon on 2025-02-26.
//

import CoreImage

final class ToneMapFilter: CIFilter {
    @objc public dynamic var inputImage: CIImage?

    override public var outputImage: CIImage? {
        guard let inputImage else { return nil }
        return Self.kernel.apply(extent: inputImage.extent, arguments: [inputImage])
    }

    private static var kernel: CIColorKernel = buildKernel()
    private static func buildKernel() -> CIColorKernel {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        return try! CIColorKernel(functionName: "ToneMapSDR", fromMetalLibraryData: data)
    }
}
