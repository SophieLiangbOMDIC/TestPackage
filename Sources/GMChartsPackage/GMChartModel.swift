//
//  GMChartModel.swift
//  GMCharts
//
//  Created by Sophie Liang on 2019/6/13.
//  Copyright © 2019 Sophie Liang. All rights reserved.
//

import Foundation
import UIKit

public struct GMChartModel {
    
    public var distance: CGFloat
    public var data: CGFloat
    
    public init(distance: CGFloat, data: CGFloat) {
        self.distance = distance
        self.data = data
    }
}
