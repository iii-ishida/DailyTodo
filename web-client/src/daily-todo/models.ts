export interface DailyTodo {
  id: string
  originalId: string
  date: string
  title: string
  order: number
  done: boolean
  doneAt: string | null
}

export function fromTodo(todo: any, date: Date): DailyTodo {
  const yyyymmdd = toYYYYMMDD(date)

  return {
    id: `${yyyymmdd}-${todo.id}`,
    originalId: todo.id,
    date: date.toISOString(),
    title: todo.title,
    order: todo.order,
    done: false,
    doneAt: null,
  }
}

export function fromFirestoreDocument(data: any): DailyTodo {
  return {
    id: data.id,
    originalId: data.originalId,
    date: data.date.toDate().toISOString(),
    title: data.title,
    order: data.order,
    done: data.done,
    doneAt: data.doneAt?.toDate().toISOString(),
  }
}

function toYYYYMMDD(date: Date): string {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  const zeroPad = (x) => (x >= 10 ? '' + x : '0' + x)

  return `${year}${zeroPad(month)}${zeroPad(day)}`
}

export interface Todo {
  id: string
  title: string
  order: number
  updatedAt: string
}

export function todoFromFirestoreDocument(data: any): Todo {
  return {
    id: data.id,
    title: data.title,
    order: data.order,
    updatedAt: data.updatedAt?.toDate().toISOString(),
  }
}

