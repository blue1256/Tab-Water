//
//  LogListViewItem.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/12.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

struct LogListViewItem: View {
    var logItem: DrinkLogItem

    var body: some View {
        HStack {
            Text(logItem.time)
                .bold()
                .frame(width: 120, alignment: .leading)
                .padding(.leading, 16)
            Divider().frame(width:1, height: 50)
            Text(String(format: "%.2lfL", logItem.volume))
                .padding(.leading, 32)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LogListViewItem_Previews: PreviewProvider {
    static var previews: some View {
        LogListViewItem(logItem: DrinkLogItem())
    }
}
