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

struct ContentView : View {
    @State var zoomed = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeroImage(name: "hero")
            
            ZStack {
                HStack {
                    TourTitle(title: "Savanna Trek", caption: "15 mile drive followed by an hour long trek")
                        .offset(x: 0, y: -15)
                        .padding(.leading, 30)
                        .offset(x: zoomed ? 500 : 0,
                                y: -15)
                        .animation(.default)
                    
                    Spacer()
                }
                
                GeometryReader() { geometry in
                    Image("thumb")
                        .clipShape(RoundedRectangle(cornerRadius: zoomed ? 40 : 500))
                        .overlay(Circle()
                                    .fill(zoomed ? Color.clear : Color(red: 1.0,
                                                                       green: 1.0,
                                                                       blue: 1.0,
                                                                       opacity: 0.4))
                                    .scaleEffect(0.8))
                        .saturation(zoomed ? 1 : 0)
                        .rotationEffect(zoomed ? .zero : .degrees(90))
                        .position(x: zoomed ? geometry.frame(in: .local).midX : 600,
                                  y: 60)
                        .scaleEffect(zoomed ? 1.33 : 0.33)
                        .shadow(radius: 10)
                        .animation(.spring())
                        .onTapGesture {
                            zoomed.toggle()
                        }

                }
            }
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            
            MilestonesList()
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPhone 11")
        }
    }
}
#endif
