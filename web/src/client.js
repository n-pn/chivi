import * as sapper from '@sapper/app'
import '$src/styles/generic.scss'

import { fetch } from 'sapper'
window._http_ = window.fetch || fetch

window._goto_ = sapper.goto

sapper.start({
  target: document.querySelector('#sapper'),
})
