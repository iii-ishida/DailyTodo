import React, { useState } from 'react'
import { TodoTemplate, todoTemplateRepo } from 'src/daily-todo'

type Props = {
  userId: string
}

const AddTodoTemplate: React.FC<Props> = ({ userId }: Props) => {
  const [formValue, setFormValue] = useState({ title: '' })

  const handleChange = (e) => {
    setFormValue({ ...formValue, ...{ [e.target.name]: e.target.value } })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    const { title } = formValue
    if (!title) {
      return
    }

    const order = await todoTemplateRepo.nextOrder(userId)
    todoTemplateRepo.addTodoTemplate(userId, { title, order } as TodoTemplate)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input type="text" name="title" value={formValue.title} onChange={handleChange} required />
    </form>
  )
}

export default AddTodoTemplate
