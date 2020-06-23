import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import TodoListItem from './TodoListItem'
import { Todo } from 'src/daily-todo'
import { TodoActions } from 'src/redux'
import { watchTodoList } from 'src/repo'

const TodoListContainer: React.FC = () => {
  const dispatch = useDispatch()
  const userId = useSelector((state) => state.user?.id)
  const todoList = useSelector((state) => state.todoList)

  useEffect(() => {
    if (!userId) {
      return
    }

    const subscription = watchTodoList(userId).subscribe((list) => dispatch(TodoActions.recieve(list)))

    return () => subscription.unsubscribe()
  }, [dispatch, userId])

  return <TodoList todoList={todoList} />
}

interface Props {
  todoList: Todo[]
}

const TodoList: React.FC<Props> = ({ todoList }: Props) => (
  <ul>
    {todoList.map((todo) => (
      <li key={todo.id}>
        <TodoListItem todo={todo} />
      </li>
    ))}
  </ul>
)

export default TodoListContainer
