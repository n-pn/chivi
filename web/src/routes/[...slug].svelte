<script context="module">
  export async function load({ page: { params } }) {
    const { slug } = params

    if (slug.startsWith('guide/')) {
      return { status: 301, redirect: slug.replace('guide', '/notes') }
    }

    return { status: 404, error: `${slug} not found!` }
  }
</script>
