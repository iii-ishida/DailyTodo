import React, { useState } from 'react'
import { Redirect } from 'react-router-dom'
import { useSelector } from 'react-redux'
import { useSignIn } from './hooks'

const Login: React.FC = () => {
  const isSignedIn = useSelector((state) => !!state.user)
  const signIn = useSignIn()

  const [formValue, setFormValue] = useState({ email: '', password: '' })
  const [error, setError] = useState(null)

  const handleChange = (e) => {
    setFormValue({ ...formValue, ...{ [e.target.name]: e.target.value } })
  }

  const handleSubmit = (e) => {
    e.preventDefault()

    const { email, password } = formValue
    if (!email || !password) {
      return
    }

    signIn(email, password).catch((error) => setError(error.message))
  }

  return isSignedIn ? (
    <Redirect to="/" />
  ) : (
    <div>
      <h1>ログイン</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Email</label>
          <input type="email" name="email" value={formValue.email} onChange={handleChange} autoComplete="email" required />
        </div>

        <div>
          <label>Password</label>
          <input type="password" name="password" value={formValue.password} onChange={handleChange} autoComplete="current-password" required />
        </div>

        <div>
          <p>{error}</p>
        </div>

        <button>ログイン</button>
      </form>
    </div>
  )
}

export default Login
