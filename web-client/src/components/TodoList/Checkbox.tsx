import React, { useState } from 'react'
import styles from './Checkbox.module.css'

type Props = {
  id: string
  checked: boolean | null
  onChange: (checked: boolean) => void
}

const Checkbox: React.FC<Props> = ({ id, checked: initial, onChange }: Props) => {
  const [checked, setChecked] = useState(initial)

  const handleChange = (e) => {
    onChange(e.target.checked)
    setChecked(e.target.checked)
  }

  return (
    <label>
      <input type="checkbox" id={id} className={styles.checkboxRaw} onChange={handleChange} checked={checked} />
      <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24" className={styles.checkbox}>
        <path d="M0 0h24v24H0z" fill="none" />
        <path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z" />
      </svg>
    </label>
  )
}

export default Checkbox
