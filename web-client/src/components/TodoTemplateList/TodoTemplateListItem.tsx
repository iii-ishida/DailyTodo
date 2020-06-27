import React, { useState } from 'react'
import { TodoTemplate, todoTemplateRepo } from 'src/daily-todo'

interface Props {
  userId: string
  todoTemplate: TodoTemplate
}

const TodoTemplateListItem: React.FC<Props> = ({ userId, todoTemplate }: Props) => {
  const [formValue, setFormValue] = useState({ title: todoTemplate.title })

  const handleChange = (e) => {
    setFormValue({ ...formValue, ...{ [e.target.name]: e.target.value } })
  }

  const handleSubmit = (e) => {
    e.preventDefault()

    const { title } = formValue
    if (!title) {
      return
    }

    todoTemplateRepo.updateTodoTemplate(userId, { ...todoTemplate, ...{ title } })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input type="text" name="title" value={formValue.title} onChange={handleChange} required />
    </form>
  )
}

export default TodoTemplateListItem
