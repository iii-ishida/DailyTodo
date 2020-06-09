import firebase from 'src/firebase'
import 'firebase/firestore'
import { collectionData } from 'rxfire/firestore'
import { map } from 'rxjs/operators'
import { Observable } from 'rxjs'
import { DailyTodo, fromFirestoreDocument } from 'src/daily-todo'

const db = firebase.firestore()

export function watchDailyTodoList(userId: string, date: Date): Observable<DailyTodo[]> {
  const yyyymmdd = toYYYYMMDD(date)

  return collectionData(db.collection(`users/${userId}/daily/todos/${yyyymmdd}`), 'id').pipe(map((data) => data.map(fromFirestoreDocument)))
}

function toYYYYMMDD(date: Date): string {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  const zeroPad = (x) => (x >= 10 ? '' + x : '0' + x)

  return `${year}${zeroPad(month)}${zeroPad(day)}`
}
