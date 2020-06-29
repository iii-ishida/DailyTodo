import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import TodoTemplateListItem from './TodoTemplateListItem'
import AddTodoTemplate from './AddTodoTemplate'
import { TodoTemplate, todoTemplateRepo } from 'src/daily-todo'
import { TodoTemplateActions } from 'src/redux'

const TodoTemplateListContainer: React.FC = () => {
  const dispatch = useDispatch()
  const userId = useSelector((state) => state.user?.id)
  const todoTemplateList = useSelector((state) => state.todoTemplateList)

  useEffect(() => {
    if (!userId) {
      return
    }

    const subscription = todoTemplateRepo.watchTodoTemplateList(userId).subscribe((list) => dispatch(TodoTemplateActions.recieve(list)))

    return () => subscription.unsubscribe()
  }, [dispatch, userId])

  return <TodoTemplateList userId={userId} todoTemplateList={todoTemplateList} />
}

type Props = {
  userId: string
  todoTemplateList: TodoTemplate[]
}

const TodoTemplateList: React.FC<Props> = ({ userId, todoTemplateList }: Props) => (
  <ul>
    {todoTemplateList.map((template) => (
      <li key={template.id}>
        <TodoTemplateListItem userId={userId} todoTemplate={template} />
      </li>
    ))}
    <li key={new Date().getTime()}>
      <AddTodoTemplate userId={userId} />
    </li>
  </ul>
)

export default TodoTemplateListContainer
