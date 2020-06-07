import { createSlice, configureStore, PayloadAction } from '@reduxjs/toolkit'
import { DailyTodo } from 'src/daily-todo'

const userSlice = createSlice({
  name: 'user',
  initialState: { id: '' },
  reducers: {
    signIn: (_, action: PayloadAction<string>) => ({ id: action.payload }),
    signOut: () => null,
  },
})

const dailyTodoListSlice = createSlice({
  name: 'dailyTodoList',
  initialState: [],
  reducers: {
    recieve: (_, action: PayloadAction<DailyTodo[]>) => action.payload,
  },
})

const reducer = {
  dailyTodoList: dailyTodoListSlice.reducer,
  user: userSlice.reducer,
}

export const UserActions = { ...userSlice.actions }
export const DailyTodoActions = { ...dailyTodoListSlice.actions }

export const store = configureStore({
  reducer,
  devTools: process.env.NODE_ENV !== 'production',
})
