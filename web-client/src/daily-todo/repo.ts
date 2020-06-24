import firebase from 'src/firebase'
import 'firebase/firestore'
import { collectionData } from 'rxfire/firestore'
import { map } from 'rxjs/operators'
import { Observable } from 'rxjs'
import { DailyTodo, Todo, fromFirestoreDocument, fromTodo, todoFromFirestoreDocument } from 'src/daily-todo'

const db = firebase.firestore()

function watchDailyTodoList(userId: string, date: Date): Observable<DailyTodo[]> {
  return collectionData(dailyTodoCollection(userId, date), 'id').pipe(map((data) => data.map(fromFirestoreDocument)))
}

async function createDailyTodoIfNeeded(userId: string, date: Date): Promise<boolean> {
  if (await existsDailyTodo(userId, date)) {
    return false
  }
  await copyDailyTodo(userId, date)

  return true
}

async function existsDailyTodo(userId: string, date: Date): Promise<boolean> {
  const querySnapshot = await dailyTodoCollection(userId, date).limit(1).get()
  return querySnapshot.size > 0
}

async function copyDailyTodo(userId: string, date: Date): Promise<void> {
  const querySnapshot = await todoCollection(userId).get()
  const dailyTodos = querySnapshot.docs.map((doc) => fromTodo({ id: doc.id, ...doc.data() }, date))

  const batch = db.batch()
  const collection = dailyTodoCollection(userId, date)
  dailyTodos.forEach((dailyTodo) => {
    const ref = collection.doc(dailyTodo.id)
    const dateAsTimestamp = firebase.firestore.Timestamp.fromDate(new Date(dailyTodo.date))
    batch.set(ref, { ...dailyTodo, date: dateAsTimestamp })
  })
  return batch.commit()
}

function dailyTodoCollection(userId: string, date: Date): firebase.firestore.CollectionReference {
  return db.collection(`users/${userId}/daily/todos/${toYYYYMMDD(date)}`)
}

function toYYYYMMDD(date: Date): string {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  const zeroPad = (x) => (x >= 10 ? '' + x : '0' + x)

  return `${year}${zeroPad(month)}${zeroPad(day)}`
}

function watchTodoList(userId: string): Observable<Todo[]> {
  return collectionData(todoCollection(userId), 'id').pipe(map((data) => data.map(todoFromFirestoreDocument)))
}

function todoCollection(userId: string): firebase.firestore.CollectionReference {
  return db.collection(`users/${userId}/todos`)
}

export const dailyTodoRepo = {
  watchDailyTodoList,
  createDailyTodoIfNeeded,
}

export const todoRepo = {
  watchTodoList,
}
