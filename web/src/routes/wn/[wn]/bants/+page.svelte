<script lang="ts">
  import GdreplList from '$gui/parts/dboard/GdreplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ gdroot, rplist, nvinfo } = data)
</script>

<section>
  <header>
    <p>
      <em
        >Nơi để thảo luận tổng hợp về bộ truyện, để bình luận theo chủ đề cụ
        thể, hãy vào
        <a href="/gd/b-{nvinfo.bslug}">diễn đàn</a> của bộ truyện.
      </em>
    </p>
  </header>
  <GdreplList {gdroot} {rplist} />
</section>

<style lang="scss">
  header {
    margin: 1rem 0;
  }

  // h3 {
  //   @include ftsize(lg);
  // }

  a {
    @include fgcolor(primary, 5);
    &:hover {
      @include fgcolor(primary, 4);
    }
  }

  section {
    max-width: 40rem;
    margin: 0 auto 0.75rem;
  }
</style>
