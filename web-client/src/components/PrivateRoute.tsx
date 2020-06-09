import React from 'react'
import { useSelector } from 'react-redux'
import { Route, Redirect, RouteProps } from 'react-router-dom'

interface Props extends RouteProps {
  loginPath: string
}

const PrivateRoute: React.FC<Props> = ({ children, loginPath, ...rest }: Props) => {
  const isSignedIn = useSelector((state) => !!state.user)

  return (
    <Route
      {...rest}
      render={({ location }) =>
        isSignedIn ? (
          children
        ) : (
          <Redirect
            to={{
              pathname: loginPath,
              state: { from: location },
            }}
          />
        )
      }
    />
  )
}

export default PrivateRoute
