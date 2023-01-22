//
//  UseCase.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

public protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
