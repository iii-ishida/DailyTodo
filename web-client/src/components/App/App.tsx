import React, { useState } from 'react'
import { Switch, Route } from 'react-router-dom'
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
  const [date, setDate] = useState(new Date())

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
            <TodoList date={date} onChangeDate={(date) => setDate(date)} />
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
