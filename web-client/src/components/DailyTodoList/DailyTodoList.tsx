import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { DailyTodoActions } from 'src/redux'
import DailyTodoListItem from './DailyTodoListItem'
import { watchDailyTodoList } from 'src/api'

const DailyTodoList: React.FC = () => {
  const dispatch = useDispatch()
  const userId = useSelector((state) => state.user?.id)
  const dailyTodoList = useSelector((state) => state.dailyTodoList)

  useEffect(() => {
    if (!userId) {
      return
    }
    const subscription = watchDailyTodoList(userId, new Date()).subscribe((list) => dispatch(DailyTodoActions.recieve(list)))

    return () => subscription.unsubscribe()
  }, [dispatch, userId])

  return (
    <ul>
      {dailyTodoList.map((todo) => (
        <li key={todo.id}>
          <DailyTodoListItem dailyTodo={todo} />
        </li>
      ))}
    </ul>
  )
}

export default DailyTodoList
