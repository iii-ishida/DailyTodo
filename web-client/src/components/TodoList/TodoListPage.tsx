import React from 'react'
import TodoList from './TodoList'
import styles from './TodoListPage.module.css'

type Props = {
  date: Date
}

const TodoListPage: React.FC<Props> = ({ date }: Props) => (
  <div>
    <h1 className={styles.header}>{formatDate(date)}</h1>
    <TodoList date={date} />
  </div>
)

function formatDate(date: Date): string {
  const zeroPad = (x) => (x >= 10 ? '' + x : '0' + x)

  const yyyy = date.getFullYear()
  const mm = zeroPad(date.getMonth() + 1)
  const dd = zeroPad(date.getDate())

  return `${yyyy}年${mm}月${dd}日`
}

export default TodoListPage
