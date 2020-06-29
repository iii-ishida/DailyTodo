import React from 'react'
import { Todo } from 'src/daily-todo'

type Props = {
  todo: Todo
}

const TodoListItem: React.FC<Props> = ({ todo }: Props) => {
  return <p>{todo.title}</p>
}

export default TodoListItem
