//
//  QLPreviewController.swift
//  Document App
//
//  Created by Emeric SAUTHIER on 11/18/24.
//

import UIKit

class QLPreviewController: UIViewController {

    
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Vérifier que imageName n'est pas nil
        if imageName != nil {
            // 2. Afficher l'image dans l'ImageView
            imageView.image = UIImage(named: imageName!)
        }
    }
}
