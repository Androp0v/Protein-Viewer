//
//  FileSegmentProtein.swift
//  BioViewer
//
//  Created by Raúl Montón Pinillos on 9/5/21.
//

import SwiftUI

struct FileSegmentProtein: View {

    @EnvironmentObject var dataSource: ProteinViewDataSource

    var body: some View {
            List {
                // First section hast 64pt padding to account for the
                // space under the segmented control.
                Section(header: Text("Loaded files").padding(.top, 64)) {
                    Text("Number of proteins: \(dataSource.proteinCount)")
                    Text("Number of atoms: \(dataSource.totalAtomCount)")
                }
            }
            .listStyle(GroupedListStyle())
    }
}

struct FileSegmentProtein_Previews: PreviewProvider {
    static var previews: some View {
        FileSegmentProtein()
    }
}
