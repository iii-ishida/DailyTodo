import React, { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import TodoTemplateListItem from './TodoTemplateListItem'
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

  return <TodoTemplateList todoTemplateList={todoTemplateList} />
}

interface Props {
  todoTemplateList: TodoTemplate[]
}

const TodoTemplateList: React.FC<Props> = ({ todoTemplateList }: Props) => (
  <ul>
    {todoTemplateList.map((template) => (
      <li key={template.id}>
        <TodoTemplateListItem todoTemplate={template} />
      </li>
    ))}
  </ul>
)

export default TodoTemplateListContainer
