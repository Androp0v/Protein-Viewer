//
//  PhotoModeContent.swift
//  BioViewer
//
//  Created by Raúl Montón Pinillos on 19/12/21.
//

import SwiftUI

struct PhotoModeContent: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private struct Constants {
        #if targetEnvironment(macCatalyst)
        static let spacing: CGFloat = 24
        #else
        static let spacing: CGFloat = 36
        #endif
    }
        
    var body: some View {
        
        List {
            PhotoModeContentHeaderView()
            
            Section {
                PickerRow(optionName: NSLocalizedString("Image resolution", comment: ""),
                          selectedOption: .constant(1),
                          pickerOptions: ["1024x1024", "2048x2048", "4096x4096"])
                PickerRow(optionName: NSLocalizedString("Shadow resolution", comment: ""),
                          selectedOption: .constant(1),
                          pickerOptions: ["Normal", "High", "Very high"])
                PickerRow(optionName: NSLocalizedString("Shadow smoothing", comment: ""),
                          selectedOption: .constant(1),
                          pickerOptions: ["Normal", "High", "Very high"])
                SwitchRow(title: NSLocalizedString("Clear background", comment: ""),
                          toggledVariable: .constant(true))
            }
            
            // Empty section to add spacing at the bottom of the list
            Section {
                Spacer()
                    .frame(height: 24)
                    .listRowBackground(Color.clear)
            }
        }
        .environment(\.defaultMinListHeaderHeight, 0)
        .listStyle(DefaultListStyle())
    }
}

struct PhotoModeHeader_Previews: PreviewProvider {
    static var previews: some View {
        PhotoModeContent()
            .environmentObject(PhotoModeViewModel())
    }
}
