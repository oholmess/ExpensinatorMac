//
//  SuccessOverlay.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/24/24.
//
import SwiftUI

extension View {
    func showSuccessOverlay(successTitle: String, successSubtitle: String? = nil, show: Binding<Bool>, dismissAction: @escaping () -> Void) -> some View {
        self.modifier(SuccessOverlayModifier(successTitle: successTitle, successSubtitle: successSubtitle, show: show, dismissAction: dismissAction))
    }
}

struct SuccessOverlayModifier: ViewModifier {
    var successTitle: String
    var successSubtitle: String?
    @Binding var show: Bool
    var dismissAction: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content // This represents the original content the modifier is applied to

            // Your custom error popup logic
            SuccessOverlay(successTitle: successTitle, successSubtitle: successSubtitle, show: $show, dismissAction: dismissAction)
        }
    }
}

struct SuccessOverlayPreview: View {
    var body: some View {
        ZStack {
            SuccessOverlay(successTitle: "Success!", successSubtitle: "Your request has been sent", show: .constant(true), dismissAction: {})
        }
    }
}

struct SuccessOverlay: View {
    
    var successTitle: String
    var successSubtitle: String?
    @Binding var show: Bool
    var dismissAction: () -> Void
    
    var body: some View {
        
        if show {
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            show = false
                        }
                    }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 600, height: 300)
                    .background(.white)
                    .cornerRadius(16)
                   
                VStack {
                    Image("success.check")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 43, height: 43)
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                        .padding(10)
                        .padding(.top, 20)
                    
                    Text(successTitle)
                        .font(.custom("SFProDisplay-Regular", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(CustomColor.EerieBlack)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    if let subtitle = successSubtitle {
                        Text(subtitle)
                            .font(.custom("SFProDisplay-Regular", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(CustomColor.EerieBlack).opacity(0.8)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                            .padding(.horizontal, 30)
                    }
                    
                    SuccessOverlay.dismissButton(action: dismissAction)
                        .padding(.bottom, 20)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: show)
                .foregroundColor(.clear)
                .padding(.horizontal)
                .background(.white)
                .cornerRadius(16)
                
            }
            .animation(.easeInOut, value: show)
        }
    }
}



extension SuccessOverlay {
    typealias ActionClosure = () -> Void
    
    static func dismissButton(action: @escaping ActionClosure) -> some View {
        Button(action: {
            action()
        }, label: {
            Text("Dismiss")
                .padding(.horizontal, 60)
                .font(.custom("SFProDisplay-Regular", size: 16))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.vertical, 23)
                .padding(.horizontal, 15)
                .background(CustomColor.green1)
                .cornerRadius(8)
        })
        .padding(.top)
        .buttonStyle(PlainButtonStyle())
        
    }
}

#Preview {
    SuccessOverlayPreview()
}
