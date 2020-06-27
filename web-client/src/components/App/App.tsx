import React from 'react'
import { BrowserRouter as Router, Switch, Route, Link } from 'react-router-dom'
import { useSelector } from 'react-redux'

import TodoList from 'src/components/TodoList'
import TodoTemplateList from 'src/components/TodoTemplateList'
import Loading from 'src/components/Loading'
import Login from 'src/components/Login'
import PrivateRoute from 'src/components/PrivateRoute'
import Header from 'src/components/Header'
import Sidebar from 'src/components/Sidebar'

import './App.css'
import { useWatchAuthState } from './hooks'

const App: React.FC = () => {
  const isLoadedAuthState = useWatchAuthState()
  const isSignedIn = useSelector((state) => !!state.user)

  if (!isLoadedAuthState) {
    return <Loading />
  }

  return (
    <Router>
      <Header />

      {isSignedIn && (
        <Sidebar>
          <Link to="/">Todo</Link>
          <Link to="/edit">Edit</Link>
        </Sidebar>
      )}

      <Switch>
        <PrivateRoute exact path="/">
          <TodoList />
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
