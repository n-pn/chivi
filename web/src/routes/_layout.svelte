<script>
  import { stores } from '@sapper/app'
  const { page } = stores()

  export let segment = ''

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }

  import { onMount } from 'svelte'
  import { user } from '$src/stores'

  onMount(async () => {
    const res = await fetch('_self')
    const data = await res.json()
    if (data.status == 'ok') {
      $user = { uname: data.uname, power: data.power }
    } else {
      $user = { uname: 'Khách', power: -1 }
    }
  })
</script>

<style lang="scss">
  :global(html),
  :global(body) {
    min-height: 100%;
  }

  :global(#sapper) {
    position: relative;
    min-width: 320px;
    height: 100%;
  }
</style>

<slot {segment} />
