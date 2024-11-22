//
//  DocumentTableViewController.swift
//  Document App
//
//  Created by Emeric SAUTHIER on 11/18/24.
//

import UIKit
import QuickLook

class DocumentTableViewController: UITableViewController {
    
    var fileList: [DocumentFile]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Personnalisation de la barre de navigation
        navigationItem.title = "📑 Liste des documents"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))
        
        fileList = listFileInBundle()
    }
    
    // MARK: - Table view data source
    
    // Indique au Controller combien de sections il doit afficher
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Indique au Controller combien de cellules il doit afficher
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList!.count
        // return DocumentFile.documents.count
    }
    
    // Indique au Controller comment remplir la cellule avec les données
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        let document = fileList![indexPath.row]
        cell.textLabel?.text = "\(document.title)"
        cell.detailTextLabel?.text = "\(document.size.formattedSize())"
        
        return cell
    }
    
    // Récupère la liste des documents
    func listFileInBundle() -> [DocumentFile] {
        // Récupère le dossier courant
        let fm = FileManager.default
        // Récupère le chemin absolu du dossier dans lequel les ressources sont contenues
        let path = Bundle.main.resourcePath!
        // Récupère les fichiers contenus dans le dossier
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        // Initialise un liste vide
        var documentListBundle = [DocumentFile]()
        
        // Boucle sur tous les fichiers présents dans le dossier
        for item in items {
            // Vérifie si l'extension du fichier n'est pas DS_Store mais est .png
            if !item.hasSuffix("DS_Store") { // && item.hasSuffix(".png") {
                // Récupère le chemin du fichier
                let currentUrl = URL(fileURLWithPath: path + "/" + item)
                // Récupère les informations du fichier (type, nom, taille)
                let resourcesValues = try! currentUrl.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey])
                
                // Ajout un document à la liste
                documentListBundle.append(DocumentFile(
                    title: resourcesValues.name!,
                    size: resourcesValues.fileSize ?? 0,
                    imageName: item,
                    url: currentUrl,
                    type: resourcesValues.contentType!.description)
                )
            }
        }
        // Retourne la liste de documents
        return documentListBundle
    }
    
    // On utilise plus un segue, nous devons donc utiliser le navigationController pour afficher le QLPreviewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = fileList![indexPath.row]
        
        self.instantiateQLPreviewController(withUrl: file.url)
    }
    
    // Instantiation d'un QLPreviewController
    func instantiateQLPreviewController(withUrl url: URL) {
        let qlPreviewController = QLPreviewController()
        qlPreviewController.dataSource = self
        navigationController?.pushViewController(qlPreviewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "ShowDocumentSegue" { return }
        
        // 1. Récuperer l'index de la ligne sélectionnée
        guard let index = tableView.indexPathForSelectedRow else { return }
        
        // 2. Récuperer le document correspondant à l'index
        let document = fileList![index.row]
        
        // 3. Cibler l'instance de DocumentViewController via le segue.destination
        // 4. Caster le segue.destination en DocumentViewController
        if let target = segue.destination as? DocumentViewController {
            
            // 5. Remplir la variable imageName de l'instance de DocumentViewController avec le nom de l'image du document
            target.imageName = document.imageName
        }
    }
}

// Implémentation du protocole QLPreviewControllerDataSource
extension DocumentTableViewController : QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let selectedIndex = tableView.indexPathForSelectedRow!
        return fileList![selectedIndex.row].url as QLPreviewItem
    }
}

// Partie 10
extension DocumentTableViewController : UIDocumentPickerDelegate {
    @objc func addDocument() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overFullScreen
        present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        dismiss(animated: true)
        
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // Copie du fichier
        copyFileToDocumentsDirectory(fromUrl: url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    func copyFileToDocumentsDirectory(fromUrl url: URL) {
        // On récupère le dossier de l'application, dossier où nous avons le droit d'écrire nos fichiers
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Nous créons une URL de destination pour le fichier
        let destinationUrl = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            // Puis nous copions le fichier depuis l'URL source vers l'URL de destination
            try FileManager.default.copyItem(at: url, to: destinationUrl)
            //fileList = listFileInBundle()
        } catch {
            print(error)
        }
    }
}

struct DocumentFile {
    var title: String
    var size: Int
    var imageName: String? = "nil"
    var url: URL
    var type: String
    
    static var documents = [
        DocumentFile(title: "Document 1", size: 100, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 2", size: 200, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 3", size: 300, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 4", size: 400, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 5", size: 500, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 6", size: 600, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 7", size: 700, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 8", size: 800, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 9", size: 900, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
        DocumentFile(title: "Document 10", size: 1000, imageName: nil, url: URL(string: "https://www.apple.com")!, type: "text/plain"),
    ]
}

extension Int {
    func formattedSize() -> String {
        let formatter = ByteCountFormatter()
        
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(self))
    }
}
