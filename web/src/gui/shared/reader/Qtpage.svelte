<script context="module" lang="ts">
  import { gen_mt_ai_html } from '$lib/mt_data_2'
</script>

<script lang="ts">
  import { config } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let rdpage

  export let label = ''

  $: [title, ...paras] = rdpage.get_vtran()

  $: r_mode = $config.r_mode == 2 ? 2 : 1
  $: show_z = $config.show_z

  const gen_vdata = (cdata: CV.Cvtree | string) => {
    if (typeof cdata == 'string') return cdata
    return gen_mt_ai_html(cdata, { mode: r_mode, cap: true, und: true, _qc: 0 })
  }
</script>

{#if title}
  {#if show_z}<h1 class="zdata">{rdpage.ztext[0]}</h1>{/if}
  <h1 id="L0" class="cdata" data-line="0">
    {@html gen_vdata(title)}
    {label}
  </h1>
  {#each paras as para, _idx}
    {#if show_z}<p class="zdata">{rdpage.ztext[_idx + 1]}</p>{/if}
    <p id="L{_idx + 1}" class="cdata" data-line={_idx + 1}>
      {@html gen_vdata(para)}
    </p>
  {/each}
{:else}
  <div class="d-empty">
    <div><SIcon name="loader-2" spin={true} /> Đang tải nội dung...</div>
  </div>
{/if}

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
</style>
