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

extension SavePlotSVGBrick: CBInstructionProtocol {

    func instruction() -> CBInstruction {
        .action { context in SKAction.run(self.actionBlock(context: context)) }
    }

    func actionBlock(context: CBScriptContextProtocol) -> () -> Void {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode
            else { fatalError("This should never happen!") }

        return {
            var filename = context.formulaInterpreter.interpretString(self.filename!, for: object)
            if let number = Double(filename) {
                filename = number.displayString
            }
            var paths = ""
            for i in 0..<spriteNode.penConfiguration.previousCutPositionLines.count
            {
                paths = paths + self.getLinePath(with: spriteNode.penConfiguration.previousCutPositionLines[i]!) + "\n"
            }
            paths = paths + self.getLinePath(with: spriteNode.penConfiguration.previousCutPositions)
        
            self.saveSVGPlot(with: paths, to: filename, width: Int(spriteNode.size.width), height: Int(spriteNode.size.height))
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func saveSVGPlot(with paths: String, to filename:String, width : Int, height : Int){
        var filecontent = "<svg height=\""+String(height)+"\" width=\""+String(width)+"\" xmlns=\"http://www.w3.org/2000/svg\">\n"
        var filename = filename
        
        filecontent += paths
        filecontent += "\n</svg>"
        
        print(filecontent)
        
        if(!filename.hasSuffix(".svg")){
            filename = filename + ".svg"
        }
        let file = self.getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try filecontent.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // TODO: failed to write file
        }
    }
    
    private func getLinePath(with positions:SynchronizedArray<CGPoint>) -> String{
        var path = "<path d=\"M"
        
        let positionCount = positions.count
        if positionCount > 1 {
            let startpoint = String(format: "%.2f", positions[0]?.x ?? 0) + " " + String(format: "%.2f", positions[0]?.y ?? 0) + " L"
            
            path += startpoint
            for (index, point) in positions.enumerated() where index > 0 {
                guard let lineFrom = positions[index - 1] else {
                    fatalError("This should never happen")
                }
                path = path + String(format: "%.2f", point.x) + " " + String(format: "%.2f", point.y) + " L"
            }
            path += "\" style=\"fill:none;stroke:black;stroke-width:3\"/>"
        }
        return path
    }
}
