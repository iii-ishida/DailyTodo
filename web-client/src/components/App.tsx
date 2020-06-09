import React, { useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { UserActions } from 'src/redux'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'
import './App.css'

import PrivateRoute from './PrivateRoute'
import DailyTodoList from './DailyTodoList'
import Login from './Login'
import { onAuthStateChanged, signOut } from 'src/auth'

function useSignOut() {
  const dispatch = useDispatch()

  return async () => {
    return signOut().then(() => dispatch(UserActions.signOut()))
  }
}

function useWatchAuthState() {
  const dispatch = useDispatch()

  useEffect(() => {
    const unsubscribe = onAuthStateChanged((user) => {
      if (user) {
        dispatch(UserActions.signIn(user.uid))
      } else {
        dispatch(UserActions.signOut())
      }
    })

    return () => unsubscribe()
  }, [dispatch])
}

const App: React.FC = () => {
  const signOut = useSignOut()
  useWatchAuthState()

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
