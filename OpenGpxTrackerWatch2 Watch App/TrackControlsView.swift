//
//  TrackControlsView.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 26/8/26.
//

import SwiftUI

struct TrackControlsView: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("00:00")
                        .font(.title2)
                    Text("0m")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Button {
                    
                } label: {
                    Image(systemName: "mappin")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            Button {
                
            } label: {
                Text("Start Tracking")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .tint(Color(uiColor: kGreenButtonBackgroundColor))
            HStack {
                Button {
                    
                } label: {
                    Text("Save")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .tint(Color(uiColor: kBlueButtonBackgroundColor))
                Button {
                    
                } label: {
                    Text("Reset")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .tint(Color(uiColor: kRedButtonBackgroundColor))
            }
        }
    }
}
