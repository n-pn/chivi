import * as sapper from '@sapper/app'
import '~mould/css/premade.scss'

window._goto = sapper.goto

sapper.start({
  target: document.querySelector('#sapper'),
})
