import { useState, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { UserActions } from 'src/redux'
import { onAuthStateChanged } from 'src/auth'

export function useWatchAuthState(): boolean {
  const [isLoaded, setLoaded] = useState(false)
  const dispatch = useDispatch()

  useEffect(() => {
    const unsubscribe = onAuthStateChanged((user) => {
      if (user) {
        dispatch(UserActions.signIn(user.uid))
      } else {
        dispatch(UserActions.signOut())
      }
      setLoaded(true)
    })

    return () => unsubscribe()
  }, [dispatch])

  return isLoaded
}
