import React from 'react'

interface Props {
  className?: string
  children: JSX.Element | JSX.Element[]
}

const Navigation: React.FC<Props> = ({ className, children }: Props) => (
  <nav className={className}>
    <ol>
      {[children].flat().map((child, i) => (
        <li key={i}>{child}</li>
      ))}
    </ol>
  </nav>
)

export default Navigation
