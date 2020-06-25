import { createSlice, configureStore, PayloadAction } from '@reduxjs/toolkit'
import { Todo, TodoTemplate } from 'src/daily-todo'

const userSlice = createSlice({
  name: 'user',
  initialState: { id: '' },
  reducers: {
    signIn: (_, action: PayloadAction<string>) => ({ id: action.payload }),
    signOut: () => null,
  },
})

const todoListSlice = createSlice({
  name: 'todoList',
  initialState: [],
  reducers: {
    recieve: (_, action: PayloadAction<Todo[]>) => action.payload,
  },
})

const todoTemplateListSlice = createSlice({
  name: 'todoTemplateList',
  initialState: [],
  reducers: {
    recieve: (_, action: PayloadAction<TodoTemplate[]>) => action.payload,
  },
})

const reducer = {
  todoList: todoListSlice.reducer,
  todoTemplateList: todoTemplateListSlice.reducer,
  user: userSlice.reducer,
}

export const UserActions = { ...userSlice.actions }
export const TodoActions = { ...todoListSlice.actions }
export const TodoTemplateActions = { ...todoTemplateListSlice.actions }

export const store = configureStore({
  reducer,
  devTools: process.env.NODE_ENV !== 'production',
})
