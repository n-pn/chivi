<script context="module">
  export async function preload({ query }) {
    await this.fetch('/_logout')
    const url = query.ret || '/'
    _goto(url)
  }
</script>
