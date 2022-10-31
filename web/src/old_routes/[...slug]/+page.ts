import { redirect, error } from '@sveltejs/kit';

throw new Error("@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ params: { slug } }) {
  if (slug.startsWith('notes')) {
    throw redirect(301, slug.replace('notes', '/guide'));
  } else {
    throw error(404, `${slug} not found!`);
  }
}
