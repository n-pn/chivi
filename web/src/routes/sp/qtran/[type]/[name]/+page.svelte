<script lang="ts">
  import { Footer, SIcon } from '$gui'

  import MtPage from '$gui/sects/MtPage.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ztext, cvmtl, wn_id } = data)
</script>

<header>.</header>

<MtPage {ztext} {cvmtl} {wn_id} no_title={true}>
  <Footer slot="footer">
    <div class="foot">
      <button
        class="m-btn"
        data-kbd="r"
        on:click={() => window.location.reload()}>
        <SIcon name="rotate" />
        <span>Dịch lại</span>
      </button>

      <a class="m-btn _success _fill" data-kbd="n" href="/sp/qtran">
        <span>Dịch mới</span>
      </a>
    </div>
  </Footer>
</MtPage>

<style lang="scss">
  .foot {
    @include flex($center: horz, $gap: 0.5rem);
    // justify-content: right;
  }

  header {
    padding: 0.5rem 0;
  }
</style>
