<script context="module">
  export async function load({ params: { slug } }) {
    if (slug.startsWith('guide/')) {
      return { status: 301, redirect: slug.replace('guide', '/notes') }
    } else {
      return { status: 404, error: `${slug} not found!` }
    }
  }
</script>
