import firebase from 'src/firebase'
import 'firebase/firestore'
import { collectionData } from 'rxfire/firestore'
import { map } from 'rxjs/operators'
import { Observable } from 'rxjs'
import { TodoTemplate, todoTemplateFromFirestoreDocument } from 'src/daily-todo/models'

const db = firebase.firestore()

export function watchTodoTemplateList(userId: string): Observable<TodoTemplate[]> {
  return collectionData(todoTemplateCollection(userId), 'id').pipe(map((data) => data.map(todoTemplateFromFirestoreDocument)))
}

export function todoTemplateCollection(userId: string): firebase.firestore.CollectionReference {
  return db.collection(`users/${userId}/templates`)
}

