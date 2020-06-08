import React from 'react'
import { DailyTodo } from 'src/daily-todo'

type Props = {
  dailyTodo: DailyTodo
}

const DailyTodoListItem: React.FC<Props> = ({ dailyTodo }: Props) => {
  return <p>{dailyTodo.title}</p>
}

export default DailyTodoListItem
