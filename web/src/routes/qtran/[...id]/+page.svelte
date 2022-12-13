<script lang="ts">
  import { page } from '$app/stores'
  import { make_url } from './shared'

  import { Footer, SIcon, Crumb } from '$gui'

  import MtPage from '$gui/sects/MtPage.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  const on_change = async () => {
    const url = make_url($page.url)
    data.cvdata = await fetch(url).then((r) => r.text())
  }
</script>

<Crumb tree={[['Dịch nhanh', '/qtran']]} />

<MtPage cvdata={data.cvdata} {on_change} no_title={true}>
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
