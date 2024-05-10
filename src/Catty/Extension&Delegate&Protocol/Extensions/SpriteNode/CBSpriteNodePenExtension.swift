/**
 *  Copyright (C) 2010-2024 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

extension CBSpriteNode {

    @objc func drawPenLine() {
        for i in 0..<self.penConfiguration.previousPositionLines.count
        {
            drawLineFromConfiguration(with: self.penConfiguration.previousPositionLines[i]!, mode: false)
        }
        if self.penConfiguration.previousPositions.last != self.position && penConfiguration.penDown {
            self.penConfiguration.previousPositions.append(self.position)
        }
        drawLineFromConfiguration(with: self.penConfiguration.previousPositions, mode: false)
    }
    
    @objc func drawPlotLine() {
        for i in 0..<self.penConfiguration.previousCutPositionLines.count
        {
            drawLineFromConfiguration(with: self.penConfiguration.previousCutPositionLines[i]!, mode: true)
        }
        if self.penConfiguration.previousCutPositions.last != self.position && penConfiguration.cut {
            self.penConfiguration.previousCutPositions.append(self.position)
        }
        drawLineFromConfiguration(with: self.penConfiguration.previousCutPositions, mode: true)
    }
    
    private func drawLineFromConfiguration(with positions:SynchronizedArray<CGPoint>, mode dashed:Bool){
        
        let positionCount = positions.count
        if positionCount > 1 {
            for (index, point) in positions.enumerated() where index > 0 {
                guard let lineFrom = positions[index - 1] else {
                    fatalError("This should never happen")
                }
                let lineTo = point
                if(dashed){
                    self.addDashedLine(from: lineFrom, to: lineTo, withColor: penConfiguration.color, withSize: penConfiguration.size)
                } else {
                    self.addLine(from: lineFrom, to: lineTo, withColor: penConfiguration.color, withSize: penConfiguration.size)
                }
            }
            positions.removeSubrange(0..<positionCount - 1)
        }
    }

    private func addLine(from startPoint: CGPoint, to endPoint: CGPoint, withColor color: UIColor, withSize size: CGFloat) {
        let line = LineShapeNode(pathStartPoint: startPoint, pathEndPoint: endPoint)
        line.name = SpriteKitDefines.penShapeNodeName
        line.strokeColor = color
        line.lineWidth = size
        line.zPosition = SpriteKitDefines.defaultPenZPosition

        self.scene?.addChild(line)
    }
    private func addDashedLine(from startPoint: CGPoint, to endPoint: CGPoint, withColor color: UIColor, withSize size: CGFloat) {
        let line = DashedLineShapeNode(pathStartPoint: startPoint, pathEndPoint: endPoint)
        line.name = SpriteKitDefines.penShapeNodeName
        line.strokeColor = color
        line.lineWidth = size
        line.zPosition = SpriteKitDefines.defaultPenZPosition

        self.scene?.addChild(line)
    }

}
