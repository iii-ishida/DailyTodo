import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import TodoListItem from './TodoListItem'
import { TodoActions } from 'src/redux'
import { Todo, todoRepo } from 'src/daily-todo'
import styles from './TodoList.module.css'

type ContainerProps = {
  date: Date
}

const TodoListContainer: React.FC<ContainerProps> = ({ date }: ContainerProps) => {
  const dispatch = useDispatch()
  const userId = useSelector((state) => state.user?.id)
  const todoList = useSelector((state) => state.todoList)

  useEffect(() => {
    if (!userId) {
      return
    }

    todoRepo.createTodoIfNeeded(userId, date)
  }, [userId, date])

  useEffect(() => {
    if (!userId) {
      return
    }

    const subscription = todoRepo.watchTodoList(userId, date).subscribe((list) => dispatch(TodoActions.recieve(list)))

    return () => subscription.unsubscribe()
  }, [dispatch, userId, date])

  return <TodoList userId={userId} date={date} todoList={todoList} />
}

type Props = {
  userId: string
  date: Date
  todoList: Todo[]
}

const TodoList: React.FC<Props> = ({ userId, todoList }: Props) => (
  <ul className={styles.todoList}>
    {todoList.map((todo) => (
      <li key={todo.id} className={styles.todoListItemContainer}>
        <TodoListItem userId={userId} todo={todo} />
      </li>
    ))}
  </ul>
)

export default TodoListContainer
