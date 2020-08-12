import React, { useEffect, useState } from 'react'
import styles from './Calendar.module.css'

type Props = {
  date?: Date
  max: Date
  onClick?: (Date) => void
}

const Calendar: React.FC<Props> = ({ date, max, onClick }: Props) => {
  const id = 'calendar'
  const [baseMonthDate, setBaseMonthDate] = useState(date ?? new Date())
  const prevMonthDate = new Date(baseMonthDate.getFullYear(), baseMonthDate.getMonth() - 1, 1)
  const nextMonthDate = new Date(baseMonthDate.getFullYear(), baseMonthDate.getMonth() + 1, 1)

  useEffect(() => {
    const scrollToCenterCalendar = () => {
      const calendar = document.getElementById(id)
      const firstMonth = calendar.querySelector('li')
      calendar.scrollTo(0, firstMonth.offsetHeight)
    }

    scrollToCenterCalendar()
  })

  const onScroll = (e) => {
    const scrollTop = e.target.scrollTop
    const scrollHeight = e.target.scrollHeight
    const offsetHeight = e.target.offsetHeight

    if (scrollTop === 0) {
      setBaseMonthDate(new Date(baseMonthDate.getFullYear(), baseMonthDate.getMonth() - 1, 1))
    } else if (scrollTop + offsetHeight === scrollHeight && max > nextMonthDate) {
      setBaseMonthDate(new Date(baseMonthDate.getFullYear(), baseMonthDate.getMonth() + 1, 1))
    }
  }

  return (
    <ol id={id} className={styles.calendar} onScroll={onScroll}>
      <li key={prevMonthDate.toJSON()}>
        <CalendarMonth year={prevMonthDate.getFullYear()} month={prevMonthDate.getMonth() + 1} max={max} onClick={onClick} />
      </li>
      <li key={baseMonthDate.toJSON()}>
        <CalendarMonth year={baseMonthDate.getFullYear()} month={baseMonthDate.getMonth() + 1} max={max} onClick={onClick} />
      </li>

      {nextMonthDate > max ? null : (
        <li key={nextMonthDate.toJSON()}>
          <CalendarMonth year={nextMonthDate.getFullYear()} month={nextMonthDate.getMonth() + 1} max={max} onClick={onClick} />
        </li>
      )}
    </ol>
  )
}

type CalendarMonthProps = {
  year: number
  month: number
  max: Date
  onClick?: (Date) => void
}

const CalendarMonth: React.FC<CalendarMonthProps> = ({ year, month, max, onClick }: CalendarMonthProps) => {
  const calendarDates = () => {
    const dates: Date[] = []
    const lastDayOfMonth = new Date(year, month, 0).getDate()

    for (let day = 1; day <= lastDayOfMonth; day++) {
      dates.push(new Date(year, month - 1, day))
    }

    return dates
  }

  return (
    <div>
      <h1 className={styles.monthTitle}>
        {year}年{month}月
      </h1>
      <ol className={styles.month}>
        {calendarDates().map((date) => (
          <CalendarDay key={date.toJSON()} date={date} disabled={date > max} onClick={onClick} />
        ))}
      </ol>
    </div>
  )
}

type CalendarDayProps = {
  date: Date
  disabled: boolean
  onClick?: (Date) => void
}

const CalendarDay: React.FC<CalendarDayProps> = ({ date, disabled: isDisabled, onClick }: CalendarDayProps) => {
  const handleClick = (date) => {
    if (isDisabled) {
      return
    }

    onClick?.(date)
  }

  const weekdayClass = (weekday) => {
    switch (weekday) {
      case 0:
        return styles.sun
      case 1:
        return styles.mon
      case 2:
        return styles.tue
      case 3:
        return styles.wed
      case 4:
        return styles.thu
      case 5:
        return styles.fri
      case 6:
        return styles.sat
    }
  }

  let className = `${styles.day} ${weekdayClass(date.getDay())}`
  if (isDisabled) {
    className += ' ' + styles.disabled
  }
  return (
    <li className={className} onClick={() => handleClick(date)}>
      {date.getDate()}
    </li>
  )
}

export default Calendar
