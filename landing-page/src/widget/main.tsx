import React from 'react'
import ReactDOM from 'react-dom/client'
import { WidgetStudio } from './WidgetStudio'
import '../index.css'

const root = document.getElementById('root')
if (root) {
  ReactDOM.createRoot(root).render(
    <React.StrictMode>
      <WidgetStudio />
    </React.StrictMode>
  )
}
