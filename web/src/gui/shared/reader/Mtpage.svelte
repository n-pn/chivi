<script context="module" lang="ts">
  const rmode = {
    avail: 'Chọn kết quả phân tích ngữ pháp có sẵn, ưu tiên Ernie Gram',
    mtl_1: 'HanLP Multi-task-learning với model ELECTRA SMALL',
    mtl_2: 'HanLP Multi-task-learning với model ELECTRA BASE',
    mtl_4: 'HanLP Multi-task-learning với model ERNIEGRAM',
  }

  import { data as lookup_data } from '$lib/stores/lookup_stores'
  import { call_mtran_file } from '$utils/tran_util'
</script>

<script lang="ts">
  import { config } from '$lib/stores'
  import { gen_vtran_html } from '$lib/mt_data_2'

  import type { Pager } from '$lib/pager'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { browser } from '$app/environment'
  import Status from './Status.svelte'

  export let pager: Pager
  export let rdata: CV.Chpart
  export let xargs: CV.Chopts
  export let label = ''

  let vtran: CV.Mtdata
  $: [title, ...paras] = vtran?.lines || []
  $: dsize = vtran?.dsize || [0, 0, 0]

  let need_load = browser
  $: if (need_load) load_data(xargs)

  async function load_data(xargs: CV.Chopts, rinit: RequestInit = {}) {
    const { zpage, rmode, m_alg = rmode || 'avail' } = xargs
    const finit = { ...zpage, m_alg, force: true }

    vtran = await call_mtran_file(finit, rinit, fetch)
    need_load = false

    if (vtran.error) return
    lookup_data.update((x) => ({ ...x, ctree: vtran.lines }))
  }

  $: mode = $config.r_mode == 2 ? 2 : 1

  const render = (ctree: CV.Cvtree) => {
    return gen_vtran_html(ctree, { mode, cap: true, und: true, _qc: 0 })
  }
</script>

<header><span class="label">Lựa chọn chế độ:</span></header>

<section class="switch">
  {#each Object.entries(rmode) as [m_alg, mdesc]}
    <a
      class="chip-link _active"
      href={pager.gen_url({ m_alg })}
      data-tip={mdesc}
      data-tip-loc="bottom">
      {#if xargs.m_alg == m_alg}<SIcon name="check" />{/if}<span>{m_alg}</span>
    </a>
  {/each}
</section>

<Status
  zsize={rdata.zsize}
  pdict={xargs.zpage.pdict}
  dsize={vtran?.dsize}
  mtime={vtran?.mtime} />

{#if vtran.error}
  <h1>Lỗi hệ thống:</h1>
  <p>{vtran.error || 'Không rõ lỗi mời liên hệ ban quản trị!'}</p>
{:else}
  <h1 id="L0" class="cdata" data-line="0">
    {@html render(title) + ' ' + label}
  </h1>

  {#each paras as para, _idx}
    <p id="L{_idx + 1}" class="cdata" data-line={_idx + 1}>
      {@html render(para)}
    </p>
  {:else}
    <p>Đang tải nội dung!</p>
  {/each}
{/if}
