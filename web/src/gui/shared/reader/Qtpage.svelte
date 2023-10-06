<script context="module" lang="ts">
  import { data as lookup_data } from '$lib/stores/lookup_stores'
  import {
    call_bt_zv_file,
    call_qt_v1_file,
    call_mt_ai_file,
  } from '$utils/tran_util'
  import { gen_mt_ai_html } from '$lib/mt_data_2'
</script>

<script lang="ts">
  import { browser } from '$app/environment'
  import { config } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let ztext: string[] = []
  export let ropts: CV.Rdopts
  export let label = ''
  export let state = 0

  $: mode = $config.r_mode == 2 ? 2 : 1

  const render = (cdata: CV.Cvtree | string) => {
    if (typeof cdata == 'string') return cdata
    else return gen_mt_ai_html(cdata, { mode, cap: true, und: true, _qc: 0 })
  }

  let vtran: CV.Qtdata | CV.Mtdata = { lines: [], mtime: 0, tspan: 0 }
  $: [title, ...paras] = vtran?.lines || []

  $: if (browser && state && ropts) {
    if (state < 2) vtran = { lines: [], mtime: 0, tspan: 0 }
    load_data(ropts)
  }

  const rinit = { cache: 'default' } as RequestInit

  async function load_data(ropts: CV.Rdopts) {
    if (!ropts.fpath) return { lines: [], mtime: 0, tspan: 0 }

    const finit = { ...ropts, force: true }

    let rmode = ropts.qt_rm

    if (ropts.rtype == 'mt' || rmode == 'mt_ai') {
      vtran = await call_mt_ai_file(finit, rinit, fetch)
      rmode = 'mt_ai'
    } else if (rmode == 'bt_zv') {
      vtran = await call_bt_zv_file(finit, rinit, fetch)
    } else if (rmode == 'qt_v1') {
      vtran = await call_qt_v1_file(finit, rinit, fetch)
    }

    state = 0
    if (vtran.error) return

    lookup_data.update((x) => {
      return { ...x, ropts, ztext, [rmode]: vtran.lines }
    })
  }
</script>

{#if vtran.error}
  <h1>Lỗi hệ thống:</h1>
  <p>{vtran.error || 'Không rõ lỗi, mời liên hệ ban quản trị!'}</p>
{:else if title}
  <h1 id="L0" class="cdata" data-line="0">{@html render(title)} {label}</h1>

  {#each paras as para, _idx}
    <p id="L{_idx + 1}" class="cdata" data-line={_idx + 1}>
      {@html render(para)}
    </p>
  {/each}
{:else}
  <div class="empty">
    <SIcon name="rotate" spin={true} />
    <p>Đang tải nội dung..</p>
  </div>
{/if}

<style lang="scss">
  .empty {
    @include flex-ca($gap: 0.25rem);
    height: 50vh;
    @include fgcolor(mute);
    font-style: italic;

    :global(svg) {
      font-size: 1.5em;
    }
  }
</style>
