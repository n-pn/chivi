import * as sapper from '@sapper/app'
import '$src/styles/generic.scss'

import { fetch } from 'sapper'
window.$$http = window.fetch || fetch

window.$$goto = sapper.goto

sapper.start({
  target: document.querySelector('#sapper'),
})
