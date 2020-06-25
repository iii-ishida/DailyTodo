import React from 'react'
import { TodoTemplate } from 'src/daily-todo'

interface Props {
  todoTemplate: TodoTemplate
}

const TodoTemplateListItem: React.FC<Props> = ({ todoTemplate }: Props) => {
  return <p>{todoTemplate.title}</p>
}

export default TodoTemplateListItem
