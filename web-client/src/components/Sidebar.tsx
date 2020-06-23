import React from 'react'

interface Props {
  children: JSX.Element | JSX.Element[]
}

const Sidebar: React.FC<Props> = ({ children }: Props) => (
  <nav>
    <ol>
      {[children].flat().map((child, i) => (
        <li key={i}>{child}</li>
      ))}
    </ol>
  </nav>
)

export default Sidebar
