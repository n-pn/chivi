<script context="module" lang="ts">
  import { data as lookup_data } from '$lib/stores/lookup_stores'
  import { call_mt_ai_file } from '$utils/tran_util'
</script>

<script lang="ts">
  import { config } from '$lib/stores'
  import { gen_mt_ai_html } from '$lib/mt_data_2'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { browser } from '$app/environment'

  export let ztext: string[] = []
  export let xargs: CV.Chopts
  export let label = ''
  export let dirty = true

  $: mode = $config.r_mode == 2 ? 2 : 1

  const render = (ctree: CV.Cvtree) => {
    return gen_mt_ai_html(ctree, { mode, cap: true, und: true, _qc: 0 })
  }

  let vtran: CV.Mtdata = { lines: [], mtime: 0, tspan: 0 }
  $: [title, ...paras] = vtran?.lines || []

  $: if (browser && dirty && xargs) {
    vtran = { lines: [], mtime: 0, tspan: 0 }
    load_data(xargs)
  }

  async function load_data(xargs: CV.Chopts, rinit: RequestInit = {}) {
    const { zpage, rmode } = xargs
    const finit = { ...zpage, m_alg: rmode || 'mtl_1', force: true }

    vtran = await call_mt_ai_file(finit, rinit, fetch)

    dirty = false
    if (vtran.error) return

    lookup_data.update((x) => {
      return { ...x, zpage: xargs.zpage, ztext, mt_ai: vtran.lines }
    })
  }
</script>

{#if vtran.error}
  <h1>Lỗi hệ thống:</h1>
  <p>{vtran.error || 'Không rõ lỗi mời liên hệ ban quản trị!'}</p>
{:else if title}
  <h1 id="L0" class="cdata" data-line="0">
    {@html render(title)}
    {label}
  </h1>

  {#each paras as para, _idx}
    <p id="L{_idx + 1}" class="cdata" data-line={_idx + 1}>
      {@html render(para)}
    </p>
  {/each}
{:else}
  <div class="empty">
    <SIcon name="rotate" spin={true} />
    <p>Đang tải nội dung!</p>
  </div>
{/if}

<style lang="scss">
  .empty {
    @include flex-ca($gap: 0.25rem);
    height: 50vh;
    @include fgcolor(mute);
    font-style: italic;
  }
</style>
