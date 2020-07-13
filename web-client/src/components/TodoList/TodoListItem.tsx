import React from 'react'
import Checkbox from './Checkbox'
import { Todo, todoRepo } from 'src/daily-todo'
import styles from './TodoListItem.module.css'

type Props = {
  userId: string
  todo: Todo
}

const TodoListItem: React.FC<Props> = ({ userId, todo }: Props) => {
  const handleChange = (checked) => {
    if (checked) {
      todoRepo.doneTodo(userId, todo)
    } else {
      todoRepo.undoneTodo(userId, todo)
    }
  }

  return (
    <label className={styles.todoListItem}>
      <Checkbox checked={todo.done} onChange={handleChange} />
      <span className={styles.label}>{todo.title}</span>
    </label>
  )
}

export default TodoListItem
