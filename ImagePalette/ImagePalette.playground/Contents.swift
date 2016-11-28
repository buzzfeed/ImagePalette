//: Playground - noun: a place where people can play

import UIKit
import ImagePalette
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
let testImage = UIImage(named: "activity_line")!
let config = PaletteConfiguration(image: testImage)
Palette.generateWithConfiguration(config, queue: DispatchQueue.main, completion: { cfg in
    if let color = cfg.darkVibrantSwatch?.color {
        color
    } else if let color = cfg.vibrantSwatch?.color {
        color
    } else if let color = cfg.lightVibrantSwatch?.color {
        color
    } else {
        print("no color found")
    }
})
