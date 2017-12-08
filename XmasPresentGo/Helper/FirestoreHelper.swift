//
//  FirestoreHelper.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/12/02.
//  Copyright © 2017年 touyou. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

protocol FirestoreHelperDelegate: class {
    
    func updateObjects(_ objects: [ObjectData])
}

class FirestoreHelper {

    static let shared = FirestoreHelper()

    // MARK: - Private

    private let defaultStore: Firestore!
    private var ref: DocumentReference?
    private var listener: ListenerRegistration?

    private init() {

        defaultStore = Firestore.firestore()
    }
    deinit {


        listener?.remove()
    }

    // MARK: - Internal
    internal var query: Query? {

        didSet {

            if let listener = listener {

                listener.remove()
                observeQuery()
            } else {
                
                observeQuery()
            }
        }
    }

    weak var delegate: FirestoreHelperDelegate?
    var objects: [ObjectData] = []
    var userId: String {
        
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    /// Start query observing
    internal func observeQuery() {
        guard let query = query else { return }
        stopObserving()

        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let models = snapshot.documents.map { (document) -> ObjectData in

                if let model = ObjectData(dictionary: document.data()) {
                    
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(ObjectData.self) with dictionary \(document.data())")
                }
            }

            self.objects = models
            self.delegate?.updateObjects(self.objects)
        }
    }

    /// Stop query observing
    internal func stopObserving() {

        listener?.remove()
    }

    /// Fetch Query for key and limit
    internal func fetchQuery(for key: String, limit: Int? = nil) -> Query {

        guard let limit = limit else {

            return defaultStore.collection(key)
        }

        return defaultStore.collection(key).limit(to: limit)
    }

    /// Post Data
    internal func postData(location: CLLocation, objectID: ARManager.Model) -> ObjectData? {

        let batch = self.defaultStore.batch()
        let model = ObjectData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, object: objectID.rawValue, userID: userId)
        let modelRef = self.defaultStore.collection("models").document()
        batch.setData(model.dictionary, forDocument: modelRef)

        batch.commit { error in

            guard let error = error else {

                return
            }
            print("commit error: \(error.localizedDescription)")
        }
        
        return model
    }
}

