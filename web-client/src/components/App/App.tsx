import React from 'react'
import { Switch, Redirect, Route, useHistory } from 'react-router-dom'
import { useSelector } from 'react-redux'

import TodoList from 'src/components/TodoList'
import TodoTemplateList from 'src/components/TodoTemplateList'
import Loading from 'src/components/Loading'
import Login from 'src/components/Login'
import PrivateRoute from 'src/components/PrivateRoute'
import Header from 'src/components/Header'
import Navigation from 'src/components/Navigation'

import styles from './App.module.css'
import { useWatchAuthState } from './hooks'

const App: React.FC = () => {
  const isLoadedAuthState = useWatchAuthState()
  const isSignedIn = useSelector((state) => !!state.user)

  if (!isLoadedAuthState) {
    return <Loading />
  }

  return (
    <div className={styles.container}>
        <Header className={styles.header} />

        {isSignedIn && (
          <Navigation
            routes={[
              { path: '/', label: 'Todo' },
              { path: '/edit', label: 'Edit' },
            ]}
          />
        )}

        <div className={styles.main}>
          <Switch>
            <PrivateRoute exact path="/">
              <TodoList date={new Date()} />
            </PrivateRoute>
            <PrivateRoute path="/edit">
              <TodoTemplateList />
            </PrivateRoute>
            <Route path="/login">
              <Login />
            </Route>
          </Switch>
        </div>
    </div>
  )
}

export default App
