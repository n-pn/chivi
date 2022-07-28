<script context="module" lang="ts">
  export async function load({ params: { slug } }) {
    if (slug.startsWith('notes')) {
      return { status: 301, redirect: slug.replace('notes', '/guide') }
    } else {
      return { status: 404, error: `${slug} not found!` }
    }
  }
</script>
