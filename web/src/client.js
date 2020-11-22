import * as sapper from '@sapper/app'
import '$src/styles/globals.scss'

window._goto_ = sapper.goto

sapper.start({
  target: document.querySelector('#sapper'),
})
