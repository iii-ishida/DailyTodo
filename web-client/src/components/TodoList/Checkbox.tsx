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
      <svg xmlns="http://www.w3.org/2000/svg" height="18" width="18" className={styles.checkbox}>
        <polygon fill-rule="nonzero" points="6.47727273 13.2136364 2.18181818 8.91818182 0.75 10.35 6.47727273 16.0772727 18.75 3.80454545 17.3181818 2.37272727"></polygon>
      </svg>
    </label>
  )
}

export default Checkbox
