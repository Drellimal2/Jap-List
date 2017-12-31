//
//  FirebaseUtils.swift
//  JapList
//
//  Created by Dane Miller on 12/31/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI
import UIKit

func getCurrentUser()->User?{
    return Auth.auth().currentUser
}



