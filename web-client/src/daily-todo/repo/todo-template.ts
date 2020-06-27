import firebase from 'src/firebase'
import 'firebase/firestore'
import { collectionData } from 'rxfire/firestore'
import { map } from 'rxjs/operators'
import { Observable } from 'rxjs'
import { TodoTemplate, todoTemplateFromFirestoreDocument } from 'src/daily-todo/models'

const db = firebase.firestore()

export function watchTodoTemplateList(userId: string): Observable<TodoTemplate[]> {
  return collectionData(todoTemplateCollection(userId).orderBy('order'), 'id').pipe(map((data) => data.map(todoTemplateFromFirestoreDocument)))
}

export async function nextOrder(userId: string): Promise<number> {
  const querySnapshot = await todoTemplateCollection(userId).orderBy('order', 'desc').limit(1).get()
  const data = querySnapshot.docs[0]?.data()
  return (data?.order ?? 0) + 1
}

export function addTodoTemplate(userId: string, todoTemplate: TodoTemplate): Promise<any> {
  const { title, order } = todoTemplate

  return todoTemplateCollection(userId).add({
    title,
    order,
    updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
  })
}

export function updateTodoTemplate(userId: string, todoTemplate: TodoTemplate): Promise<any> {
  const { title } = todoTemplate

  return todoTemplateCollection(userId).add({
    title,
    updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
  })
}

export function todoTemplateCollection(userId: string): firebase.firestore.CollectionReference {
  return db.collection(`users/${userId}/templates`)
}
