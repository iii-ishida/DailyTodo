import React, { useState } from 'react'
import styles from './Checkbox.module.css'

type Props = {
  id?: string
  checked: boolean | null
  onChange: (checked: boolean) => void
}

const Checkbox: React.FC<Props> = ({ id, checked: initial, onChange }: Props) => {
  const [checked, setChecked] = useState(initial)

  const handleChange = (e) => {
    onChange(e.target.checked)
    setChecked(e.target.checked)
  }

  let containerClass = styles.container
  if (checked) {
    containerClass += ' ' + styles.checked
  }

  return (
    <label className={containerClass}>
      <input type="checkbox" id={id} className={styles.checkboxRaw} checked={checked} onChange={handleChange} />
      <svg xmlns="http://www.w3.org/2000/svg" className={styles.checkbox} viewBox="0 0 24 24" width="18px" height="18px">
        <path d="M9 16L5 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z" />
      </svg>
    </label>
  )
}

export default Checkbox
