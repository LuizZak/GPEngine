//
//  GameEventReceiver.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 05/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// A protocol to be implemented by classed that receive events fired by the game screen
public protocol GameEventListener {
    // Receives an event fired by the game screen
    func receiveEvent(_ event: GameEvent)
}
