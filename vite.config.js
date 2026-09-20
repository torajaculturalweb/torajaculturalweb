import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // Relative assets make one build work on localhost, Vercel, and GitHub Pages.
  base: './',
})
