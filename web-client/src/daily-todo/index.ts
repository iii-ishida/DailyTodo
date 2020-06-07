export interface DailyTodo {
  id: string
  originalId: string
  date: string
  title: string
  order: number
  done: boolean
  doneAt: string | null
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
