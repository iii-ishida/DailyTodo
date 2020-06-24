import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import DailyTodoListItem from './DailyTodoListItem'
import { DailyTodoActions } from 'src/redux'
import { DailyTodo, dailyTodoRepo } from 'src/daily-todo'

const DailyTodoListContainer: React.FC = () => {
  const dispatch = useDispatch()
  const userId = useSelector((state) => state.user?.id)
  const dailyTodoList = useSelector((state) => state.dailyTodoList)

  useEffect(() => {
    if (!userId) {
      return
    }

    dailyTodoRepo.createDailyTodoIfNeeded(userId, new Date())
  }, [userId])

  useEffect(() => {
    if (!userId) {
      return
    }

    const subscription = dailyTodoRepo.watchDailyTodoList(userId, new Date()).subscribe((list) => dispatch(DailyTodoActions.recieve(list)))

    return () => subscription.unsubscribe()
  }, [dispatch, userId])

  return <DailyTodoList dailyTodoList={dailyTodoList} />
}

interface Props {
  dailyTodoList: DailyTodo[]
}

const DailyTodoList: React.FC<Props> = ({ dailyTodoList }: Props) => (
  <ul>
    {dailyTodoList.map((todo) => (
      <li key={todo.id}>
        <DailyTodoListItem dailyTodo={todo} />
      </li>
    ))}
  </ul>
)

export default DailyTodoListContainer
