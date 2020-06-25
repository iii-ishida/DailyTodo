import firebase from 'src/firebase'
import 'firebase/firestore'
import { collectionData } from 'rxfire/firestore'
import { map } from 'rxjs/operators'
import { Observable } from 'rxjs'
import { Todo, todoFromTodoTemplate, todoFromFirestoreDocument } from 'src/daily-todo/models'
import { todoTemplateCollection } from './todo-template'

const db = firebase.firestore()

export function watchTodoList(userId: string, date: Date): Observable<Todo[]> {
  return collectionData(todoCollection(userId, date), 'id').pipe(map((data) => data.map(todoFromFirestoreDocument)))
}

export async function createTodoIfNeeded(userId: string, date: Date): Promise<boolean> {
  if (await existsTodo(userId, date)) {
    return false
  }
  await copyTodo(userId, date)

  return true
}

async function existsTodo(userId: string, date: Date): Promise<boolean> {
  const querySnapshot = await todoCollection(userId, date).limit(1).get()
  return querySnapshot.size > 0
}

async function copyTodo(userId: string, date: Date): Promise<void> {
  const querySnapshot = await todoTemplateCollection(userId).get()
  const todos = querySnapshot.docs.map((doc) => todoFromTodoTemplate({ id: doc.id, ...doc.data() }, date))

  const batch = db.batch()
  const collection = todoCollection(userId, date)
  todos.forEach((todo) => {
    const ref = collection.doc(todo.id)
    const dateAsTimestamp = firebase.firestore.Timestamp.fromDate(new Date(todo.date))
    batch.set(ref, { ...todo, date: dateAsTimestamp })
  })
  return batch.commit()
}

function todoCollection(userId: string, date: Date): firebase.firestore.CollectionReference {
  return db.collection(`users/${userId}/dates/${toYYYYMMDD(date)}/todos`)
}

function toYYYYMMDD(date: Date): string {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  const zeroPad = (x) => (x >= 10 ? '' + x : '0' + x)

  return `${year}${zeroPad(month)}${zeroPad(day)}`
}

