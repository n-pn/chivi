<script context="module">
  export async function preload({ query }) {
    await this.fetch('/api/logout')
    _goto_(query.ret || '/')
  }
</script>
