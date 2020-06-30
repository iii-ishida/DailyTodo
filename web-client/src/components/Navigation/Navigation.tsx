import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import styles from './Navigation.module.css'

type Route = {
  path: string
  label: string
}

type Props = {
  routes: Route[]
}

const Navigation: React.FC<Props> = ({ routes }: Props) => {
  const location = useLocation()

  return (
    <nav>
      <ol>
        {routes.map(({ path, label }) => {
          let className = styles.navigationItem
          if (path === location.pathname) {
            className += ' ' + styles.selected
          }

          return (
            <li key={path + label}>
              <Link to={path} className={className}>
                {label}
              </Link>
            </li>
          )
        })}
      </ol>
    </nav>
  )
}

export default Navigation
