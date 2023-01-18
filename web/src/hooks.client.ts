import type { HandleClientError } from '@sveltejs/kit'

export const handleError = (({ error }) => {
  // console.log(event)
  console.log({ error })
  return { message: error.toString(), code: 'UNKNOWN' }
}) satisfies HandleClientError
