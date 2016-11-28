//
//  PaletteSwatch.swift
//  ImagePalette
//
//  Original created by Google/Android
//  Ported to Swift/iOS by Shaun Harrison
//

import Foundation
import UIKit

/** Represents a color swatch generated from an image's palette. */
open class PaletteSwatch {
	fileprivate static let MIN_CONTRAST_TITLE_TEXT = CGFloat(3.0)
	fileprivate static let MIN_CONTRAST_BODY_TEXT = CGFloat(4.5)

	fileprivate let rgb: RGBColor
	fileprivate let hex: Int64

	/** This swatch's color */
	open let color: UIColor

	/** The number of pixels represented by this swatch */
	open let population: Int64

	fileprivate var generatedTextColors: Bool = false
	fileprivate var _titleTextColor: UIColor?
	fileprivate var _bodyTextColor: UIColor?

	fileprivate var _hsl: HSLColor?

	public convenience init(color: UIColor, population: Int64) {
		self.init(rgbColor: RGBColor(color: color), population: population)
	}

	internal convenience init(color: HSLColor, population: Int64) {
		self.init(rgbColor: color.rgb, population: population)
	}

	internal init(rgbColor: RGBColor, population: Int64) {
		self.rgb = rgbColor
		self.hex = rgbColor.hex
		self.color = rgbColor.color
		self.population = population
	}

	/**
	Return this swatch's HSL values.
	*/
	internal var hsl: HSLColor {
		if let hsl = self._hsl {
			return hsl
		} else {
			let hsl = self.rgb.hsl
			self._hsl = hsl
			return hsl
		}
	}

	/**
	* An appropriate color to use for any 'title' text which is displayed over this
	* Swatch's color. This color is guaranteed to have sufficient contrast.
	*/
	open var titleTextColor: UIColor? {
		self.ensureTextColorsGenerated()
		return self._titleTextColor
	}

	/**
	* An appropriate color to use for any 'body' text which is displayed over this
	* Swatch's color. This color is guaranteed to have sufficient contrast.
	*/
	open var bodyTextColor: UIColor? {
		self.ensureTextColorsGenerated()
		return self._bodyTextColor
	}

	fileprivate func ensureTextColorsGenerated() {
		if (!self.generatedTextColors) {
			// First check white, as most colors will be dark
			let lightBodyAlpha = HexColor.calculateMinimumAlpha(HexColor.WHITE, background: hex, minContrastRatio: type(of: self).MIN_CONTRAST_BODY_TEXT)
			let lightTitleAlpha = HexColor.calculateMinimumAlpha(HexColor.WHITE, background: hex, minContrastRatio: type(of: self).MIN_CONTRAST_TITLE_TEXT)

			if let lightBodyAlpha = lightBodyAlpha, let lightTitleAlpha = lightTitleAlpha {
				// If we found valid light values, use them and return
				self._bodyTextColor = UIColor(white: 1.0, alpha: CGFloat(lightBodyAlpha) / 255.0)
				self._titleTextColor = UIColor(white: 1.0, alpha: CGFloat(lightTitleAlpha) / 255.0)

				self.generatedTextColors = true
				return
			}

			let darkBodyAlpha = HexColor.calculateMinimumAlpha(HexColor.BLACK, background: hex, minContrastRatio: type(of: self).MIN_CONTRAST_BODY_TEXT)
			let darkTitleAlpha = HexColor.calculateMinimumAlpha(HexColor.BLACK, background: hex, minContrastRatio: type(of: self).MIN_CONTRAST_TITLE_TEXT)

			if let darkBodyAlpha = darkBodyAlpha, let darkTitleAlpha = darkTitleAlpha {
				// If we found valid dark values, use them and return
				self._bodyTextColor = UIColor(white: 0.0, alpha: CGFloat(darkBodyAlpha) / 255.0)
				self._titleTextColor = UIColor(white: 0.0, alpha: CGFloat(darkTitleAlpha) / 255.0)

				self.generatedTextColors = true
				return
			}

			// If we reach here then we can not find title and body values which use the same
			// lightness, we need to use mismatched values
			if let lightBodyAlpha = lightBodyAlpha {
				self._bodyTextColor = UIColor(white: 1.0, alpha: CGFloat(lightBodyAlpha) / 255.0)
			} else if let darkBodyAlpha = darkBodyAlpha {
				self._bodyTextColor = UIColor(white: 0.0, alpha: CGFloat(darkBodyAlpha) / 255.0)
			}

			if let lightTitleAlpha = lightTitleAlpha {
				self._titleTextColor = UIColor(white: 1.0, alpha: CGFloat(lightTitleAlpha) / 255.0)
			} else if let darkTitleAlpha = darkTitleAlpha {
				self._titleTextColor = UIColor(white: 0.0, alpha: CGFloat(darkTitleAlpha) / 255.0)
			}

			self.generatedTextColors = true
		}
	}

}

extension PaletteSwatch: CustomDebugStringConvertible {

	public var debugDescription: String {
		var description = "<\(type(of: self)) 0x\(self.hashValue)"
		description += "; color = \(self.color)"
		description += "; hsl = \(self._hsl)"
		description += "; population = \(self.population)"
		description += "; titleTextColor = \(self.titleTextColor)"
		description += "; bodyTextColor = \(self.bodyTextColor)"
		return description + ">"
	}

}

extension PaletteSwatch: Equatable, Hashable {

	public var hashValue: Int {
        let maxInt = Int64(Int32.max)
		return Int((31 * self.color.hashValue + self.population) % maxInt)
	}

}

public func ==(lhs: PaletteSwatch, rhs: PaletteSwatch) -> Bool {
	return lhs.population == rhs.population && lhs.rgb == rhs.rgb
}

