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

class FirestoreHelper {

    static let shared = FirestoreHelper()

    // MARK: - Private

    private let defaultStore: Firestore!
    private var ref: DocumentReference?
    private var listener: ListenerRegistration?

    private init() {

        FirebaseApp.configure()
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
            }
        }
    }

    var objects: [ObjectData] = []

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
    internal func postData(location: CLLocation, objectID: ARManager.Model) {

        let userID = ""

        // TODO: userのIDをUUIDでを決める
        let batch = self.defaultStore.batch()
        let model = ObjectData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, object: objectID, userID: userID)
        let userRef = self.defaultStore.collection("users").document(userID).collection("model").document()
        batch.setData(model.dictionary, forDocument: userRef)

        batch.commit { error in

            guard let error = error else {

                return
            }
            print("commit error: \(error.localizedDescription)")
        }
    }
}

