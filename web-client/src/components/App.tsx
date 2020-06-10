import React, { useState, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'

import './App.css'
import DailyTodoList from './DailyTodoList'
import Loading from './Loading'
import Login from './Login'
import PrivateRoute from './PrivateRoute'
import { onAuthStateChanged, signOut } from 'src/auth'
import { UserActions } from 'src/redux'

function useSignOut() {
  const dispatch = useDispatch()

  return async () => {
    return signOut().then(() => dispatch(UserActions.signOut()))
  }
}

function useWatchAuthState() {
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

const App: React.FC = () => {
  const signOut = useSignOut()
  const isLoadedAuthState = useWatchAuthState()

  if (!isLoadedAuthState) {
    return <Loading />
  }

  return (
    <Router>
      <Switch>
        <PrivateRoute exact path="/" loginPath="/login">
          <DailyTodoList />
          <button onClick={() => signOut()}>ログアウト</button>
        </PrivateRoute>
        <Route path="/login">
          <Login />
        </Route>
      </Switch>
    </Router>
  )
}

export default App
