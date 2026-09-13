import { resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'

const __dirname = fileURLToPath(new URL('.', import.meta.url))

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
    {
      name: 'rewrite-widget-route',
      configureServer(server) {
        server.middlewares.use((req, _res, next) => {
          if (req.url === '/widget' || req.url === '/widget/') {
            req.url = '/widget/index.html'
          }
          next()
        })
      },
      configurePreviewServer(server) {
        server.middlewares.use((req, res, next) => {
          if (req.url === '/widget') {
            res.writeHead(302, { Location: '/widget/' })
            res.end()
            return
          }
          next()
        })
      },
    },
  ],
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        widget: resolve(__dirname, 'widget/index.html'),
      },
    },
  },
})
