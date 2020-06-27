import React from 'react'
import { useDispatch } from 'react-redux'
import { signOut } from 'src/auth'
import { UserActions } from 'src/redux'

function useSignOut(): () => Promise<any> {
  const dispatch = useDispatch()

  return async () => {
    return signOut().then(() => dispatch(UserActions.signOut()))
  }
}

const Header: React.FC = () => {
  const signOut = useSignOut()

  return (
    <header>
      <h1>Title</h1>
      <button onClick={() => signOut()}>ログアウト</button>
    </header>
  )
}

export default Header
