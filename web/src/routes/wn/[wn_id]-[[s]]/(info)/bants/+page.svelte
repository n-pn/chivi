<script lang="ts">
  import MureplList from '$gui/parts/dboard/MureplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ thread, rplist, nvinfo } = data)
</script>

<section>
  <header>
    <h3>Bình luận chung cho bộ truyện {nvinfo.vtitle}</h3>
    <p><em>Để bình luận các chủ đề cụ thể hơn, hãy vào diễn đàn.</em></p>
  </header>
  <MureplList {thread} {rplist} />
</section>

<style lang="scss">
  header {
    margin-bottom: 1rem;
  }

  h3 {
    @include ftsize(lg);
  }

  section {
    max-width: 40rem;
    margin: 0 auto 0.75rem;
  }
</style>
