<script lang="ts">
  import { Footer, SIcon } from '$gui'

  import MtPage from '$gui/sects/MtPage2.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ztext, cvmtl, wn_id } = data)
</script>

<MtPage {ztext} {cvmtl} {wn_id}>
  <Footer slot="footer">
    <div class="foot">
      <button
        class="m-btn"
        data-kbd="r"
        on:click={() => window.location.reload()}>
        <SIcon name="rotate" />
        <span>Dịch lại</span>
      </button>

      <a class="m-btn _success _fill" data-kbd="n" href="/qtran">
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
</style>
