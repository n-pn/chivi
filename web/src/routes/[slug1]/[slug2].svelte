<script context="module">
  export async function preload({ params }) {
    this.redirect(301, `/~${params.slug1}/${params.slug2}`)
  }
</script>
