import * as sapper from '@sapper/app'
import '$src/styles/premade.scss'

// import { fetch } from 'sapper'
// window.fetch = window.fetch || fetch

window._goto = sapper.goto

sapper.start({
  target: document.querySelector('#sapper'),
})
