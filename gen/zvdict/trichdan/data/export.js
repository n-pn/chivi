import * as fs from 'fs'
import { hanData } from './handict.js'

const names = hanData.names

const data = []

for (const [hanzi, hanviet] of names) {
  const viets = hanviet.split(',').filter((x) => x)
  data.push([hanzi, ...viets].join('\t'))
}

fs.writeFileSync('gen/zvdict/trichdan/hanzi.tsv', data.join('\n'))
