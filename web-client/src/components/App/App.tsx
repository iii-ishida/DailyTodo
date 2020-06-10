import React from 'react'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'

import DailyTodoList from 'src/components/DailyTodoList'
import Loading from 'src/components/Loading'
import Login from 'src/components/Login'
import PrivateRoute from 'src/components/PrivateRoute'

import './App.css'
import { useSignOut, useWatchAuthState } from './hooks'

const App: React.FC = () => {
  const signOut = useSignOut()
  const isLoadedAuthState = useWatchAuthState()

  if (!isLoadedAuthState) {
    return <Loading />
  }

  return (
    <Router>
      <Switch>
        <PrivateRoute exact path="/">
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
