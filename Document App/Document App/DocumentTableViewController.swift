//
//  DocumentTableViewController.swift
//  Document App
//
//  Created by Emeric SAUTHIER on 11/18/24.
//

import UIKit
import QuickLook

class DocumentTableViewController: UITableViewController {
    
    let sections = ["Importés", "Bundle"]
    
    var fileList: [DocumentFile]?
    var fileListFiltered: [DocumentFile]?
    
    var importList: [DocumentFile]?
    var importListFiltered: [DocumentFile]?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Personnalisation de la barre de navigation
        navigationItem.title = "📑 Liste des documents"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))
        
        fileList = listFileInBundle()
        importList = listImportedFiles()
        fileListFiltered = fileList
        importListFiltered = importList
        
        setupSearchController()
    }
    
    
    // MARK: - Table view data source
    
    // Indique au Controller combien de sections il doit afficher
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // Indique le titre de la section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    // Indique au Controller combien de cellules il doit afficher
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? importListFiltered!.count : fileListFiltered!.count
        // return DocumentFile.documents.count
    }
    
    // Indique au Controller comment remplir la cellule avec les données
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        let document = indexPath.section == 0 ? importListFiltered![indexPath.row] : fileListFiltered![indexPath.row]
        cell.textLabel?.text = "\(document.title)"
        cell.detailTextLabel?.text = "\(document.size.formattedSize())"
        
        return cell
    }
    
    
    // MARK: - Récupération des fichiers
    
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
    
    // Récupère les fichiers importés
    func listImportedFiles() -> [DocumentFile] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Récupération des url des fichiers du dossier
        let items = try! FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
        
        var documentsList = [DocumentFile]()
        
        for item in items {
            // Récupération des infos du fichier
            let resourcesValues = try! item.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey])
            
            // Ajout un document à la liste
            documentsList.append(DocumentFile(
                title: resourcesValues.name!,
                size: resourcesValues.fileSize ?? 0,
                imageName: item.lastPathComponent,
                url: item,
                type: resourcesValues.contentType!.description)
            )
        }
        
        return documentsList
    }
    
    
    // MARK: - Renvoi vers la vue de détail
    
    // Instantiation d'un QLPreviewController
    func instantiateQLPreviewController(withUrl url: URL) {
        let qlPreviewController = QLPreviewController()
        qlPreviewController.dataSource = self
        navigationController?.pushViewController(qlPreviewController, animated: true)
    }
    
    // Avec segue
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


// MARK: - QLPreviewController

// Implémentation du protocole QLPreviewControllerDataSource
extension DocumentTableViewController : QLPreviewControllerDataSource {
    // On utilise plus un segue, nous devons donc utiliser le navigationController pour afficher le QLPreviewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var file: DocumentFile
        if indexPath.section == 0 {
            file = importListFiltered![indexPath.row]
        }
        else {
            file = fileListFiltered![indexPath.row]
        }
        
        self.instantiateQLPreviewController(withUrl: file.url)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let selectedIndex = tableView.indexPathForSelectedRow!
        
        if selectedIndex.section == 0 {
            return importListFiltered![selectedIndex.row].url as QLPreviewItem
        }
        return fileListFiltered![selectedIndex.row].url as QLPreviewItem
    }
}


// MARK: - DocumentPicker

// Partie 10
extension DocumentTableViewController : UIDocumentPickerDelegate {
    @objc func addDocument() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overFullScreen
        
        present(documentPicker, animated: true)
    }
    
    // Sélection d'un fichier
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
        
        // Reload data
        tableView.reloadData()
    }
    
    // Prise en compte du cas où l'on quitte sans sélectionner de fichier
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    // Copie du fichier dans le dossier de l'application
    func copyFileToDocumentsDirectory(fromUrl url: URL) {
        // On récupère le dossier de l'application, dossier où nous avons le droit d'écrire nos fichiers
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Nous créons une URL de destination pour le fichier
        let destinationUrl = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            // Puis nous copions le fichier depuis l'URL source vers l'URL de destination
            try FileManager.default.copyItem(at: url, to: destinationUrl)
            
            // Récupération des infos du fichiers
            let resourcesValues = try! destinationUrl.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey])
            
            // Ajout du document à la liste des documents importés
            self.importList!.append(DocumentFile(
                title: resourcesValues.name!,
                size: resourcesValues.fileSize ?? 0,
                imageName: destinationUrl.lastPathComponent,
                url: destinationUrl,
                type: resourcesValues.contentType!.description)
            )
        } catch {
            print(error)
        }
    }
}


// MARK: - Search Bar
extension DocumentTableViewController : UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    // Mise à jour de l'affichage en fonction des filtres
    func updateSearchResults(for searchController: UISearchController) {
        fileListFiltered = fileList
        importListFiltered = importList
        
        if let searchBarText = searchController.searchBar.text?.lowercased() {
            // Lorsque le champs de saisie est vide, on refresh et on sort de la méthode
            guard !searchBarText.isEmpty else { tableView.reloadData(); return }
            
            fileListFiltered = fileListFiltered!.filter({ $0.title.lowercased().contains(searchBarText) })
            importListFiltered = importListFiltered!.filter({ $0.title.lowercased().contains(searchBarText) })
        }
        
        // Refresh des données
        tableView.reloadData()
    }
    
    // Initialisation du searchController
    func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Rechercher un document"
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.setImage(UIImage(systemName: "line.horizontal.3.decrease"), for: .bookmark, state: .normal)
    }
}


// MARK: - Structure DocumentFile
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


// MARK: - Extension de Int

extension Int {
    func formattedSize() -> String {
        let formatter = ByteCountFormatter()
        
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(self))
    }
}
