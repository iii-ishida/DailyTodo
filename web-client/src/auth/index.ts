import firebase from 'src/firebase'
import 'firebase/auth'

const auth = firebase.auth()

export interface User {
  id: string
  email: string
}

export async function createUserWithEmailAndPassword(email: string, password: string): Promise<User> {
  const { user } = await auth.createUserWithEmailAndPassword(email, password)
  return { id: user.uid, email: user.email }
}

export async function signInWithEmailAndPassword(email: string, password: string): Promise<User> {
  const { user } = await auth.signInWithEmailAndPassword(email, password)
  return { id: user.uid, email: user.email }
}

export function signOut(): Promise<void> {
  return auth.signOut()
}

export function onAuthStateChanged(callback) {
  return auth.onAuthStateChanged((user) => {
    callback(user)
  })
}
