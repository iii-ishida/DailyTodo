import React, { useState, useRef } from 'react'
import TodoList from './TodoList'
import Calendar from './Calendar'
import styles from './TodoListPage.module.css'
import Modal from 'react-modal'

Modal.setAppElement('#root')

type Props = {
  date: Date
  onChangeDate: (Date) => void
}

const TodoListPage: React.FC<Props> = ({ date, onChangeDate }: Props) => {
  const [showDatePicker, setShowDatePicker] = useState(false)
  const dateButton = useRef(null)

  const onOpenDialog = () => {
    setShowDatePicker(true)
  }
  const onCloseDialog = () => {
    setShowDatePicker(false)
  }
  const handleChange = (date) => {
    onCloseDialog()
    onChangeDate(date)
  }

  const modalStyle = {
    content: {
      top: dateButton.current?.offsetTop,
      left: dateButton.current?.offsetLeft,
      width: 'fit-content',
      height: 'fit-content',
      padding: 0,
    },
  }

  return showDatePicker ? (
    <Modal style={modalStyle} isOpen={showDatePicker} onRequestClose={onCloseDialog}>
      <Calendar date={date} max={date} onClick={handleChange} />
    </Modal>
  ) : (
    <div>
      <h1 className={styles.header} ref={dateButton}>
        <button onClick={onOpenDialog}>{formatDate(date)}</button>
      </h1>
      <TodoList date={date} />
    </div>
  )
}

function formatDate(date: Date): string {
  const zeroPad = (x) => (x >= 10 ? '' + x : '0' + x)

  const yyyy = date.getFullYear()
  const mm = zeroPad(date.getMonth() + 1)
  const dd = zeroPad(date.getDate())

  return `${yyyy}年${mm}月${dd}日`
}

export default TodoListPage
