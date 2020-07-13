import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import TodoListItem from './TodoListItem'
import { TodoActions } from 'src/redux'
import { Todo, todoRepo } from 'src/daily-todo'
import styles from './TodoList.module.css'

const TodoListContainer: React.FC = () => {
  const dispatch = useDispatch()
  const userId = useSelector((state) => state.user?.id)
  const todoList = useSelector((state) => state.todoList)
  const date = new Date()

  useEffect(() => {
    if (!userId) {
      return
    }

    todoRepo.createTodoIfNeeded(userId, new Date())
  }, [userId])

  useEffect(() => {
    if (!userId) {
      return
    }

    const subscription = todoRepo.watchTodoList(userId, date).subscribe((list) => dispatch(TodoActions.recieve(list)))

    return () => subscription.unsubscribe()
  }, [dispatch, userId])

  return <TodoList userId={userId} date={date} todoList={todoList} />
}

type Props = {
  userId: string
  date: Date
  todoList: Todo[]
}

const TodoList: React.FC<Props> = ({ userId, date, todoList }: Props) => (
  <div>
    <h1 className={styles.header}>{formatDate(date)}</h1>
    <ul className={styles.todoList}>
      {todoList.map((todo) => (
        <li key={todo.id} className={styles.todoListItemContainer}>
          <TodoListItem userId={userId} todo={todo} />
        </li>
      ))}
    </ul>
  </div>
)

function formatDate(date: Date): string {
  const zeroPad = (x) => (x >= 10 ? '' + x : '0' + x)

  const yyyy = date.getFullYear()
  const mm = zeroPad(date.getMonth() + 1)
  const dd = zeroPad(date.getDate())

  return `${yyyy}年${mm}月${dd}日`
}

export default TodoListContainer
