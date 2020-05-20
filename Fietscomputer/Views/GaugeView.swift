//
//  GaugeView.swift
//  Fietscomputer
//
//  Created by Grigory Avdyushin on 01/05/2020.
//  Copyright © 2020 Grigory Avdyushin. All rights reserved.
//

import SwiftUI

struct GaugeView<ViewModel: GaugeViewModel>: View {

    @ObservedObject var viewModel: ViewModel
    @State var offset = CGSize.zero

    var body: some View {
        Text(viewModel.value)
            .minimumScaleFactor(0.4)
            .scaledFont(name: viewModel.fontName, size: CGFloat(viewModel.fontSize))
    }
}
