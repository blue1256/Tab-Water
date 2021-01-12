//
//  OpenSourceDetailView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/12.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

struct OpenSourceDetailView: View {
    var license: OpenSourceLicensesView.OpenSourceInfo
    
    var body: some View {
        ScrollView {
            Text(license.content)
        }
        .navigationBarTitle(Text(license.name))
    }
}

struct OpenSourceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        OpenSourceDetailView(license: OpenSourceLicensesView.OpenSourceInfo(name: "name", content: "content"))
    }
}
