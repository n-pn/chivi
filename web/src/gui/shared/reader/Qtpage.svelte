<script context="module" lang="ts">
  import { gen_mt_ai_html } from '$lib/mt_data_2'
</script>

<script lang="ts">
  import { browser } from '$app/environment'

  import { config } from '$lib/stores'
  import type { Rdpage } from '$lib/reader'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let rpage: Rdpage
  export let label = ''
  export let state = 1

  const load_vdata = async (rpage: Rdpage, force: boolean = true) => {
    if (state == 0) {
      return rpage.get_vtran()
    } else {
      state = 0
      return await rpage.load_vtran(1, force)
    }
  }

  $: r_mode = $config.r_mode == 1 ? 1 : 2
  $: show_z = $config.show_z

  const gen_vdata = (cdata: CV.Cvtree | string, mode: number = 1) => {
    if (typeof cdata == 'string') return cdata
    return gen_mt_ai_html(cdata, { mode, cap: true, und: true, _qc: 0 })
  }
</script>

{#await browser && load_vdata(rpage, true)}
  <div class="d-empty">
    <div class="m-flex _cx">
      <SIcon name="loader" spin={true} />
      <span>Đang tải nội dung...</span>
    </div>
  </div>
{:then vdata}
  {@const [title, ...paras] = vdata || []}
  {#if title}
    {#if show_z}<h1 class="zdata">{rpage.ztext[0]}</h1>{/if}
    <h1 id="L0" class="cdata" class:debug={$config.r_mode == 2} data-line="0">
      {@html gen_vdata(title, r_mode)}
      {label}
    </h1>
    {#each paras as para, _idx}
      {#if show_z}<p class="zdata">{rpage.ztext[_idx + 1]}</p>{/if}
      <p
        id="L{_idx + 1}"
        class="cdata"
        class:debug={$config.r_mode == 2}
        data-line={_idx + 1}>
        {@html gen_vdata(para, r_mode)}
      </p>
    {/each}
  {:else}
    <div class="d-empty">
      <div class="m-flex _cx">
        <SIcon name="loader" spin={true} />
        <span>Đang tải nội dung...</span>
      </div>
    </div>
  {/if}
{:catch err}
  <div class="d-empty">Lỗi tải dữ liệu: {err}</div>
{/await}

<style lang="scss">
  .d-empty {
    :global(svg) {
      font-size: 1.5em;
    }
  }

  .zdata {
    @include fgcolor(tert);
    margin-bottom: 0;

    & + .cdata {
      margin-top: 0;
    }
  }

  .m-flex {
    gap: 0.25rem;
  }
</style>
