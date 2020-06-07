import { useDispatch } from 'react-redux'
import { UserActions } from 'src/redux'
import { signInWithEmailAndPassword } from 'src/auth'

export function useSignIn() {
  const dispatch = useDispatch()

  return async (email, password) => {
    const user = await signInWithEmailAndPassword(email, password)
    return dispatch(UserActions.signIn(user.id))
  }
}
