/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct SpinnerView: View {
    @State var completed = false
    @State var currentIndex: Int?
    @State var isVisible = true
    @State var currentOffset = CGSize.zero
    
    struct Leaf: View {
        let rotation: Angle
        let isCurrent: Bool
        let isCompleting: Bool
        
        var body: some View {
            Capsule()
                .fill(isCurrent ? Color.white : Color.blue)
                .frame(width: 16, height: isCompleting ? 16 : 40)
                .offset(x: isCurrent ? 8 : 0, y: isCurrent ? 32 : 56)
                .scaleEffect(isCurrent ? 0.4 : 0.8)
                .rotationEffect(isCompleting ? .zero
                                    : rotation)
                .animation(.easeInOut(duration: 1.2))
        }
    }
    
    let leavesCount = 12
    
    let shootUp = AnyTransition.offset(CGSize(width: 0,
                                              height: -1000))
        .animation(.easeIn(duration: 0.8))
    
    var body: some View {
        VStack {
            if isVisible {
                ZStack {
                    ForEach(0..<leavesCount) { index in
                        Leaf(rotation: .degrees(Double(index) / Double(leavesCount)) * 360,
                             isCurrent: index == currentIndex,
                             isCompleting: completed)
                    }
                }
                .offset(currentOffset)
                .blur(radius: currentOffset == .zero ? 0 : 10)
                .animation(.easeInOut(duration: 1.0))
                .gesture(
                    DragGesture()
                        .onChanged({ gesture in
                            currentOffset = gesture.translation
                        })
                        .onEnded({ gesture in
                            if currentOffset.height > 150 {
                                complete()
                            }
                            currentOffset = .zero
                        })
                )
                .transition(shootUp)
                .onAppear(perform: animate)
            }
        }
    }
    
    func animate() {
        var iteration = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.15,
                             repeats: true) { timer in
            if let index = currentIndex {
                currentIndex = (index + 1) % leavesCount
            } else {
                currentIndex = 0
            }
            
            iteration += 1
            if iteration == 60 {
                timer.invalidate()
                complete()
            }
        }
    }
    
    func complete() {
        guard !completed else { return }
        
        completed = true
        currentIndex = nil
        delay(seconds: 2) {
            isVisible = false
        }
    }
}

#if DEBUG
struct SpinnerView_Previews : PreviewProvider {
    static var previews: some View {
        SpinnerView()
    }
}
#endif
