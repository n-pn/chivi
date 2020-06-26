<script lang="typescript">
  export let segment : string = ''
  import { stores } from '@sapper/app'
  const { page } = stores()

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }
</script>

<slot {segment} />
