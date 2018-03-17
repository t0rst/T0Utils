/*
	CollectionViewUtils.swift
	T0Utils

	Created by Torsten Louland on 05/03/2018.

	MIT License

	Copyright (c) 2018 Torsten Louland

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

import UIKit



public typealias FlowLayoutSizingRequest = UICollectionViewFlowLayout.SizingRequest



extension UICollectionViewFlowLayout
{
	open func fixedSizeItems(inArea: CGSize, includeHeader: Bool = false) -> (maxRows: Int, maxCols: Int)? {
		var available = inArea
		let insets = sectionInset
		available.width -= insets.left + insets.right
		available.height -= insets.top + insets.bottom
		if includeHeader {
			switch scrollDirection {
				case .horizontal:	available.width -= headerReferenceSize.width
				case .vertical:		available.height -= headerReferenceSize.height
			}
		}

		let accountForContentInset: Bool
		if #available(iOS 11.0, *) {
			accountForContentInset = sectionInsetReference == .fromContentInset
		} else {
			accountForContentInset = true
		}
		if accountForContentInset, let insets = collectionView?.contentInset {
			available.width -= insets.left + insets.right
			available.height -= insets.top + insets.bottom
		}

		let maxAcross	=
			available.width <= 0
		  ? 0
		  : Int(floor(	(available.width + minimumInteritemSpacing)
					  / (itemSize.width + minimumInteritemSpacing) ))
		let maxDown	=
			available.height <= 0
		  ? 0
		  : Int(floor(	(available.height + minimumLineSpacing)
					  / (itemSize.height + minimumLineSpacing) ))
		return maxDown > 0 && maxAcross > 0
			 ? (maxRows: maxDown, maxCols: maxAcross)
			 : nil
	}
	
	open func minSize(forCols cols: Int, rows: Int, includeHeader: Bool = false) -> CGSize {
		guard cols > 0, rows > 0 else { return .zero }
		var size = CGSize.zero
		size.width	= CGFloat(cols) * (itemSize.width + minimumInteritemSpacing)
									- minimumInteritemSpacing
		size.height	= CGFloat(rows) * (itemSize.height + minimumLineSpacing)
									- minimumLineSpacing
		let insets = sectionInset
		size.width += insets.left + insets.right
		size.height += insets.top + insets.bottom
		if includeHeader {
			switch scrollDirection {
				case .horizontal:	size.width += headerReferenceSize.width
				case .vertical:		size.height += headerReferenceSize.height
			}
		}

		let accountForContentInset: Bool
		if #available(iOS 11.0, *) {
			accountForContentInset = sectionInsetReference == .fromContentInset
		} else {
			accountForContentInset = true
		}
		if accountForContentInset, let insets = collectionView?.contentInset {
			size.width += insets.left + insets.right
			size.height += insets.top + insets.bottom
		}

		return size
	}

	public enum FitType {
		case allInNColumns(Int), allInNRows(Int)
		case allVisibleFewestColumns, allVisibleFewestRows
		case scrollInMaxNColumns(Int), scrollInMaxNRows(Int)
		public static let vertical: [FitType] = [.allInNColumns(1), .allVisibleFewestColumns, .scrollInMaxNColumns(2)]
		public static let horizontal: [FitType] = [.allInNRows(1), .allVisibleFewestRows, .scrollInMaxNRows(2)]
	}
	open func sizeToFit(itemCount count: Int, inArea available: CGSize, preferFit fitTypes: [FitType] = FitType.vertical)
		  -> (size: CGSize, fitCount: Int)?
	{
		guard count > 0, let (maxRows, maxCols) = fixedSizeItems(inArea: available)
		else { return nil }

		var rows = 0, cols = 0, fitCount = 0
		for ft in fitTypes {
			switch ft {
			case .allInNColumns(let n) where n > 0 && count < maxRows * n:
				cols = n
				rows = (count - 1) / n + 1
				fitCount = count
			case .allInNRows(let n) where n > 0 && count < maxCols * n:
				rows = n
				cols = (count - 1) / n + 1
				fitCount = count
			case .allVisibleFewestColumns:
				if count <= maxRows * maxCols {
					cols = (count + maxRows - 1) / maxRows
					rows = (count + cols - 1) / cols
					fitCount = count
				}
			case .allVisibleFewestRows:
				if count <= maxRows * maxCols {
					rows = (count + maxCols - 1) / maxCols
					cols = (count + rows - 1) / rows
					fitCount = count
				}
			case .scrollInMaxNColumns(let n) where n > 0 && n <= maxCols:
				cols = min(n, maxCols)
				rows = maxRows
				fitCount = rows * cols
			case .scrollInMaxNRows(let n) where n > 0 && n <= maxRows:
				rows = min(n, maxRows)
				cols = maxCols
				fitCount = rows * cols
			default:
				break
			}
			if fitCount > 0 { break }
		}
		guard fitCount > 0
		else { return nil }
		let preferredSize = minSize(forCols: cols, rows: rows)
		return (preferredSize, Int(fitCount))
	}

	/// `SizingRequest` conveys a request to `dynamicItemSize(forRequest:)` for explicit size (using `width`/`height`) or size to fit a count in the available space (using `rows`/`cols`), requestable independently for each direction. Zero values defer to non-zero, and fit count defers to explicit size. If both size and count are zero, a count of 1 in that direction is assumed. In the scrolling direction, a non-integral count is allowed, giving the number of items visible at any time. In the non-scrolling dimension, count is rounded, with a minimum of one.
	public struct SizingRequest {
		public let width:			CGFloat
		public let columns:			CGFloat
		public let height:			CGFloat
		public let rows:			CGFloat
		public let ignoreHeader:	Bool
		public init(sizes s: CGSize, counts c: CGSize, ignoreHeader ih: Bool = false)
		{ width = s.width ; height = s.height ; columns = c.width ; rows = c.height ; ignoreHeader = ih }
		public init(width w: CGFloat = 0, columns c: CGFloat = 0, height h: CGFloat = 0, rows r: CGFloat = 0, ignoreHeader ih: Bool = true)
		{ width = w ; columns = c ; height = h ; rows = r ; ignoreHeader = ih }
	}
	/// Calculate the itemSize to fulfill the sizing request, given the current values for scroll direction, spacing, insets and the size of the collection view; see description of `SizingRequest`.
	open func dynamicItemSize(for request: SizingRequest) -> CGSize {
		guard let cv = collectionView
		else { return itemSize }

		var size: CGSize = .zero

		if request.width > 0 {
			size.width = request.width
		} else {
			var cols = max(1, request.columns)
			if scrollDirection == .vertical {
				cols = round(cols)
			}
			let inset = minSize(forCols: 1, rows: 1).width - itemSize.width
			let gap = scrollDirection == .vertical ? minimumInteritemSpacing : minimumLineSpacing
			let available = cv.bounds.size.width - inset + gap
			size.width = available / cols - gap
			let scale = UIScreen.main.scale
			size.width = trunc(size.width * scale) / scale
		}

		if request.height > 0 {
			size.height = request.height
		} else {
			var rows = max(1, request.rows)
			if scrollDirection == .horizontal {
				rows = round(rows)
			}
			let inset = minSize(forCols: 1, rows: 1, includeHeader: !request.ignoreHeader).height
					  - itemSize.height
			let gap = scrollDirection == .horizontal ? minimumInteritemSpacing : minimumLineSpacing
			let available = cv.bounds.size.height - inset + gap
			size.height = available / rows - gap
			let scale = UIScreen.main.scale
			size.height = trunc(size.height * scale) / scale
		}

		return size
	}
}



