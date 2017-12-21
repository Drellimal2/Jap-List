//
//  GCDBlackBox.swift
//  JapList
//
//  Created by Dane Miller on 12/21/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
