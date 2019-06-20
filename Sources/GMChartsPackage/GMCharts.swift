//
//  GMCharts.swift
//  GMCharts
//
//  Created by Sophie Liang on 2019/6/13.
//  Copyright © 2019 Sophie Liang. All rights reserved.
//

import UIKit

public class GMCharts: UIView {
    
    enum Direction {
        case right, left
    }
    
    public enum Unit: String {
        case km, mile
    }
    
    public var edge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 60)
    public var chartBottom: CGFloat = 60.0
    public var labelColor: UIColor = .white
    public var labelSize: CGFloat = 10
    public var space: CGFloat = 10
    public var borderColor: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
    
    private var rTopLabel: UILabel = UILabel()
    private var rMidLabel: UILabel = UILabel()
    private var rBottomLabel: UILabel = UILabel()
    
    private var lTopLabel: UILabel = UILabel()
    private var lBottomLabel: UILabel = UILabel()
    
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    private var chartMinX: CGFloat = 0
    private var chartMaxX: CGFloat = 0
    private var chartMinY: CGFloat = 0
    private var chartMaxY: CGFloat = 0
    private var chartHeight: CGFloat = 0
    private var chartWidth: CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    public func redraw() {
        width = frame.width
        height = frame.height
        chartMinX = edge.left
        chartMaxX = width - edge.right
        chartMinY = edge.top
        chartMaxY = height - edge.bottom - chartBottom
        chartHeight = chartMaxY - chartMinY
        chartWidth = chartMaxX - chartMinX
        
        drawBorder()
    }
    
    func drawBorder() {
        
        let path = UIBezierPath()
        // 畫左邊的線
        path.move(to: CGPoint(x: chartMinX, y: chartMinY))
        path.addLine(to: CGPoint(x: chartMinX, y: chartMaxY))
        
        // 畫右邊的線
        path.move(to: CGPoint(x: chartMaxX, y: chartMinY))
        path.addLine(to: CGPoint(x: chartMaxX, y: chartMaxY))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = borderColor.cgColor
        layer.addSublayer(shapeLayer)
        
    }
    
    func setLabels() {
        drawLabel(label: rTopLabel, rl: .right, y: chartMinY - space)
        drawLabel(label: rMidLabel, rl: .right, y: (height - chartBottom) / 2)
        drawLabel(label: rBottomLabel, rl: .right, y: height - chartBottom)
        
        drawLabel(label: lTopLabel, rl: .left, y: chartMinY - space)
        drawLabel(label: lBottomLabel, rl: .left, y: height - chartBottom)
    }
    
    func drawLabel(label: UILabel, rl: Direction, y: CGFloat) {
        let x = (rl == .right) ? chartMaxX : 5
        let width = (rl == .right) ? (chartMaxX - 5) : chartMinX
        
        label.frame = CGRect(x: x, y: y - labelSize, width: width, height: 40)
        label.textColor = labelColor
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(name: "Avenir", size: labelSize)
        label.text = ""
        self.addSubview(label)
    }
    
    public func drawLine(array: [GMChartModel], color: UIColor, unit: Unit, isFilled: Bool = false) {
        
        let maxData = (array.max(by: { $0.data < $1.data }) ?? GMChartModel(distance: 0, data: 0)).data
        let minData = (array.min(by: { $0.data < $1.data }) ?? GMChartModel(distance: 0, data: 0)).data
        
        // 分隔線的x間距
        let maxDistance = (array.max(by: { $0.distance < $1.distance }) ?? GMChartModel(distance: 0, data: 0)).distance
        var separators = getSeparatorArray(distance: maxDistance)
        separators.append(Double(maxDistance))
        let sepX = chartWidth / (CGFloat(separators.count))
        
        var datas: [[CGFloat]] = []
        
        for (index, i) in separators.enumerated() {
            if index > 0 {
                datas.append(array.filter { CGFloat(separators[index - 1]) < $0.distance && $0.distance <= CGFloat(i) }.map{ $0.data })
            } else {
                datas.append(array.filter { $0.distance <= CGFloat(i) }.map{ $0.data })
            }
        }
        
        for (index, data) in datas.enumerated() {
            
            let path = UIBezierPath()
            var startY: CGFloat = 0
            let startX: CGFloat = chartMinX + CGFloat(index) * sepX
            let endX: CGFloat = startX + sepX

            // 每個點之間的x間距
            let disX = sepX / CGFloat(data.count)
            
            for (index, item) in data.enumerated() {
                
                let a = chartHeight / (maxData - minData) * (maxData - item)
                let y = a + edge.top
                
                if index == 0 {
                    startY = y
                    path.move(to: CGPoint(x: startX, y: y))
                    
                } else if index == array.count - 1 {
                    path.addLine(to: CGPoint(x: startX, y: y))
                    
                } else {
                    path.addLine(to: CGPoint(x: startX + disX * CGFloat(index), y: y))
                    
                }
            }
            
            if isFilled {
                path.addLine(to: CGPoint(x: endX, y: chartMaxY))
                path.addLine(to: CGPoint(x: startX, y: chartMaxY))
                path.addLine(to: CGPoint(x: startX, y: startY))
            }
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.lineWidth = 1.0
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.fillColor = isFilled ? color.cgColor : nil
            
            layer.addSublayer(shapeLayer)

        }
    }
    
    public func drawSeparators(distance: CGFloat, unit: Unit, color: UIColor = .white) {
        
        let separators = getSeparatorArray(distance: distance)
        
        drawBottomLabel(text: "0", x: chartMinX, width: 20)
        drawBottomLabel(text: String(format: "%.2f %@", distance, unit.rawValue), x: chartMaxX + edge.right - 50, width: 50)

        //每個點的x間距
        let disX = chartWidth / (CGFloat(separators.count) + 1)
        
        for (index, item) in separators.enumerated() {
            let x = chartMinX + disX * CGFloat(index + 1)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: x, y: chartMinY))
            path.addLine(to: CGPoint(x: x, y: chartMaxY))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.lineWidth = 1.0
            shapeLayer.strokeColor = color.cgColor
            layer.addSublayer(shapeLayer)
            
            drawBottomLabel(text: "\(item)", x: x, width: 20)
        }
    }
    
    func drawBottomLabel(text: String, x: CGFloat, width: CGFloat) {
        let label = UILabel(frame: CGRect(x: x, y: height - edge.bottom, width: width, height: 20))
        label.textColor = .yellow
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir", size: 10)
        label.text = text
        self.addSubview(label)
    }
    
    func getSeparatorArray(distance: CGFloat) -> [Double] {
        var array: [Double] = []
        switch distance {
        case 2...3:
            array = [1]
        case 3...4:
            array = [1, 2]
        case 4...5:
            array = [1, 2, 3]
        case 5...6:
            array = [1, 2, 3, 4]
        case 6...7:
            array = [2, 4]
        case 7...9:
            array = [2, 4, 6]
        case 9...11:
            array = [2, 4, 6, 8]
        case 11...13:
            array = [3, 6, 9]
        case 13...16:
            array = [3, 6, 9, 12]
        case 16...17:
            array = [4, 8, 12]
        case 17...25:
            array = [4, 8, 12, 16]
        default:
            break
        }
        return array
    }

}
