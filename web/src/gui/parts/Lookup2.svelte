<script lang="ts">
  import { ctrl, data, init_opts } from '$lib/stores/lookup_stores'
  import { call_mt_ai_file } from '$utils/tran_util'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Vtform, {
    data as vtform_data,
    ctrl as vtform_ctrl,
  } from '$gui/parts/VitermForm.svelte'

  import Overview from './Sideline/Overview.svelte'
  import Glossary from './Sideline/Glossary.svelte'
  import Analysis from './Sideline/Analysis.svelte'

  export let ropts = init_opts
  export let state = 0
  export let l_idx = 0
  export let l_max = 0

  let zfrom = 0
  let zupto = 1

  const node_names = ['X-N', 'X-C', 'X-Z']

  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return

    zfrom = +target.dataset.b
    zupto = +target.dataset.e

    if ($ctrl.panel != 'glossary') {
      const icpos = target.dataset.c || 'X'

      const ztext = $data.ztext[l_idx]
      const hviet = $data.hviet[l_idx]
      const mt_ai = $data.mt_ai[l_idx]

      vtform_data.put(ztext, hviet, mt_ai, zfrom, zupto, icpos)
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

  let viewer: HTMLElement

  let stale = false
  $: if (stale) load_mt_ai_data()

  const rinit = { cache: 'no-cache' } as RequestInit
  $: finit = { ...$data.ropts, force: true }

  const load_mt_ai_data = async () => {
    stale = false

    if (ropts.rtype == 'mt' || ropts.qt_rm == 'mt_ai') {
      state = 2
    } else {
      const mt_ai = await call_mt_ai_file(finit, rinit)
      $data.mt_ai = mt_ai.lines || []
    }
  }
</script>

<Slider
  class="lookup"
  _sticky={true}
  bind:actived={$ctrl.actived}
  --slider-width="30rem">
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="compass" /></div>
    <div class="-text">Chi tiết</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      type="button"
      class="-btn"
      class:_active={$ctrl.panel == 'overview'}
      data-kbd="d"
      data-tip="Xem các kết quả dịch"
      data-tip-loc="bottom"
      on:click={() => ($ctrl.panel = 'overview')}>
      <SIcon name="world" />
    </button>
    <button
      type="button"
      class="-btn"
      class:_active={$ctrl.panel == 'glossary'}
      data-kbd="f"
      data-tip="Xem giải nghĩa từ"
      data-tip-loc="bottom"
      on:click={() => ($ctrl.panel = 'glossary')}>
      <SIcon name="search" />
    </button>
    <button
      type="button"
      class="-btn"
      class:_active={$ctrl.panel == 'analyis'}
      data-kbd="g"
      data-tip="Xem cây ngữ pháp"
      data-tip-loc="bottom"
      on:click={() => ($ctrl.panel = 'analyis')}>
      <svg class="m-icon _analyze" viewBox="0 0 24 24">
        <path stroke="none" d="M0 0h24v24H0z" fill="none" />
        <path
          d="M20 11a8.1 8.1 0 0 0 -6.986 -6.918a8.095 8.095 0 0 0 -8.019 3.918" />
        <path d="M4 13a8.1 8.1 0 0 0 15 3" />
        <path d="M19 16m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" />
        <path d="M5 8m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" />
        <path d="M12 12m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" />
      </svg>
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
      <Overview {l_idx} bind:stale />
    {:else if $ctrl.panel == 'glossary'}
      <Glossary {l_idx} {viewer} bind:zfrom bind:zupto />
    {:else}
      <Analysis {l_idx} bind:stale />
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
        class="m-btn _sm _primary _fill"
        data-kbd="e"
        data-tip="Thêm sửa bản dịch thủ công cho dòng"
        disabled={true}>
        <SIcon name="edit" />
        <span class="-txt">Dịch dòng!</span>
      </button>

      <button
        type="button"
        class="m-btn _sm"
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
  <Vtform ropts={$data.ropts} on_close={(term) => (stale = !!term)} />
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
