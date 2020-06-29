import React from 'react'
import { useDispatch } from 'react-redux'
import { signOut } from 'src/auth'
import { UserActions } from 'src/redux'
import logo from './logo.svg'
import styles from './Header.module.css'

function useSignOut(): () => Promise<any> {
  const dispatch = useDispatch()

  return async () => {
    return signOut().then(() => dispatch(UserActions.signOut()))
  }
}

type Props = {
  className?: string
}

const Header: React.FC<Props> = ({ className }: Props) => {
  const signOut = useSignOut()

  return (
    <header className={`${className} ${styles.header}`}>
      <a href="/">
        <img src={logo} className={styles.logo} alt="logo" />
      </a>
      <button className={styles.signOutButton} onClick={() => signOut()}>
        ログアウト
      </button>
    </header>
  )
}

export default Header
