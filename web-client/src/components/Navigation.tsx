import React from 'react'

interface Props {
  children: JSX.Element | JSX.Element[]
}

const Navigation: React.FC<Props> = ({ children }: Props) => (
  <nav>
    <ol>
      {[children].flat().map((child, i) => (
        <li key={i}>{child}</li>
      ))}
    </ol>
  </nav>
)

export default Navigation
