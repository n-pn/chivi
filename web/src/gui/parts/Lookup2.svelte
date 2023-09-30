<script lang="ts">
  import { ctrl, data } from '$lib/stores/lookup_stores'
  import { call_mtran_file } from '$utils/tran_util'

  import { page } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Vtform, {
    data as vtform_data,
    ctrl as vtform_ctrl,
  } from '$gui/parts/VitermForm.svelte'

  import Overview from './Sideline/Overview.svelte'
  import Glossary from './Sideline/Glossary.svelte'

  export let l_idx = 0
  export let l_max = 0

  let zfrom = 0
  let zupto = 1

  const node_names = ['X-N', 'X-C', 'X-Z']

  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return

    zfrom = +target.dataset.b
    zupto = +target.dataset.e

    if ($ctrl.panel == 'overview') {
      const icpos = target.dataset.c || 'X'

      const ztext = $data.ztext[l_idx]
      const hviet = $data.hviet[l_idx]
      const ctree = $data.ctree[l_idx]

      vtform_data.put(ztext, hviet, ctree, zfrom, zupto, icpos)
      vtform_ctrl.show(0)
    }
  }

  function handle_ctxmenu(event: MouseEvent) {
    const target = event.target as HTMLElement
    if (!node_names.includes(target.nodeName)) return

    event.preventDefault()

    zfrom = +target.dataset.b
    zupto = +target.dataset.e
    $ctrl.panel = 'glossary'
  }

  $: finit = { ...$data.zpage, m_alg: $data.m_alg, force: true }
  const rinit = { cache: 'no-cache' } as RequestInit

  let reload_ctree = false
  $: if (reload_ctree) load_ctree_data()

  const load_ctree_data = async () => {
    reload_ctree = false

    if ($page.data.xargs?.rtype != 'ai') {
      const ctree = await call_mtran_file(finit, rinit)
      $data.ctree = ctree.lines || []
    } else {
      await invalidate('wn:cdata')
      $data.ctree = $page.data.vtran.lines
    }
  }

  let viewer: HTMLElement
</script>

<Slider
  class="lookup"
  _sticky={true}
  bind:actived={$ctrl.actived}
  --slider-width="30rem">
  <svelte:fragment slot="header-left">
    <div class="-text">Phân tích</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      type="button"
      class="-btn"
      class:_active={$ctrl.panel == 'overview'}
      data-kbd="f"
      data-tip="Xem các kết quả dịch"
      data-tip-loc="bottom"
      on:click={() => ($ctrl.panel = 'overview')}>
      <SIcon name="info-circle" />
    </button>
    <button
      type="button"
      class="-btn"
      class:_active={$ctrl.panel == 'glossary'}
      data-kbd="g"
      data-tip="Xem giải nghĩa từ"
      data-tip-loc="bottom"
      on:click={() => ($ctrl.panel = 'glossary')}>
      <SIcon name="compass" />
    </button>
  </svelte:fragment>
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <section
    class="cbody"
    bind:this={viewer}
    on:click={handle_click}
    on:contextmenu={handle_ctxmenu}>
    {#if $ctrl.panel == 'overview'}
      <Overview {l_idx} {reload_ctree} />
    {:else}
      <Glossary {l_idx} {viewer} bind:zfrom bind:zupto />
    {/if}
  </section>

  <Footer slot="foot">
    <footer class="foot">
      <button
        type="button"
        class="m-btn _sm"
        data-kbd="↑"
        data-tip="Chuyển lên dòng trên"
        disabled={l_idx == 0}
        on:click={() => (l_idx -= 1)}>
        <SIcon name="arrow-up" />
        <span class="-txt">Trên</span>
      </button>
      <button
        type="button"
        class="m-btn _sm _primary"
        data-kbd="↓"
        data-tip="Chuyển xuống dòng dưới"
        on:click={() => (l_idx += 1)}
        disabled={l_idx + 1 == l_max}>
        <SIcon name="arrow-down" />
        <span class="-txt">Dưới</span>
      </button>
    </footer>
  </Footer>
</Slider>

{#if $vtform_ctrl.actived}
  <Vtform zpage={$data.zpage} on_close={(term) => (reload_ctree = !!term)} />
{/if}

<style lang="scss">
  .cbody {
    padding: 0 0.75rem;
    flex: 1;

    :global(.cdata._ct x-n) {
      color: var(--active);
      font-weight: 450;
      border: 0;
      &:hover {
        border-bottom: 1px solid var(--border);
      }
    }
  }

  .foot {
    @include flex-ca($gap: 0.5rem);
  }
</style>
