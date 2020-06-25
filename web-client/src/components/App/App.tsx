import React from 'react'
import { BrowserRouter as Router, Switch, Route, Link } from 'react-router-dom'
import { useSelector } from 'react-redux'

import DailyTodoList from 'src/components/DailyTodoList'
import TodoTemplateList from 'src/components/TodoTemplateList'
import Loading from 'src/components/Loading'
import Login from 'src/components/Login'
import PrivateRoute from 'src/components/PrivateRoute'
import Sidebar from 'src/components/Sidebar'

import './App.css'
import { useSignOut, useWatchAuthState } from './hooks'

const App: React.FC = () => {
  const signOut = useSignOut()
  const isLoadedAuthState = useWatchAuthState()
  const isSignedIn = useSelector((state) => !!state.user)

  if (!isLoadedAuthState) {
    return <Loading />
  }

  return (
    <Router>
      {isSignedIn && (
        <Sidebar>
          <Link to="/">Todo</Link>
          <Link to="/edit">Edit</Link>
        </Sidebar>
      )}

      <Switch>
        <PrivateRoute exact path="/">
          <DailyTodoList />
          <button onClick={() => signOut()}>ログアウト</button>
        </PrivateRoute>
        <PrivateRoute path="/edit">
          <TodoTemplateList />
        </PrivateRoute>
        <Route path="/login">
          <Login />
        </Route>
      </Switch>
    </Router>
  )
}

export default App
