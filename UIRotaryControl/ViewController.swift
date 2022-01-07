//
//  ViewController.swift
//  UIRotaryControl
//
//  Created by Gopi Krishnan on 25/12/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let smallControl : UIRotaryControl = UIRotaryControl()
        let bigControl : UIRotaryControl = UIRotaryControl(imageName: "bg_bigger")
       
        let view1 = UIView()
        view1.addSubview(smallControl)
        smallControl.pointerColor = .black
        smallControl.maximumValue = 8
        smallControl.minimumValue = 2

        
        let view2 = UIView()
        bigControl.maximumValue = 13
        bigControl.minimumValue = 1
        bigControl.type = .stepped
        bigControl.stepperValue = 0.75
        view2.addSubview(bigControl)
        
        let viewStack = UIStackView(frame: CGRect.init(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 1000))
        viewStack.axis = .vertical
        viewStack.translatesAutoresizingMaskIntoConstraints = false
        viewStack.distribution = .equalSpacing
        viewStack.alignment = .center
        viewStack.spacing = 80
        viewStack.addArrangedSubview(view1)
        viewStack.addArrangedSubview(view2)
        self.view.addSubview(viewStack)
        
        viewStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        viewStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        view1.heightAnchor.constraint(equalToConstant:smallControl.frame.size.height).isActive = true
        view1.widthAnchor.constraint(equalToConstant: smallControl.frame.size.width).isActive = true
        view1.centerXAnchor.constraint(equalTo: viewStack.centerXAnchor).isActive = true
        view1.topAnchor.constraint(equalTo: viewStack.topAnchor).isActive = true
        
        view2.heightAnchor.constraint(equalToConstant: bigControl.frame.size.height).isActive = true
        view2.widthAnchor.constraint(equalToConstant: bigControl.frame.size.width).isActive = true
        view2.centerXAnchor.constraint(equalTo: viewStack.centerXAnchor).isActive = true
        self.view.backgroundColor = .white

    }


}

