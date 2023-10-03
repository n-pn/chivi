<script context="module" lang="ts">
  type Mode = Record<string, Record<string, string>>

  const all_descs: Mode = {
    qt: {
      qt_v1: 'Dịch thô bằng máy dịch phiên bản cũ',
      bt_zv: 'Dịch thô bằng công cụ Bing Translator',
      mt_ai: 'Dịch thô bằng máy dịch mới (dữ liệu Electra Small)',
    },

    mt: {
      mtl_1: 'HanLP Multi-task-learning với model ELECTRA SMALL',
      mtl_2: 'HanLP Multi-task-learning với model ELECTRA BASE',
      mtl_3: 'HanLP Multi-task-learning với model ERNIE GRAM',
    },
  }

  const all_modes: Mode = {
    qt: {
      qt_v1: 'Dịch máy cũ',
      bt_zv: 'Dịch bằng Bing',
      mt_ai: 'Dịch máy mới',
    },

    mt: {
      mtl_1: 'Electra Small',
      mtl_2: 'Electra Base',
      mtl_3: 'Ernie Gram',
    },
  }
</script>

<script lang="ts">
  import type { Pager } from '$lib/pager'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let pager: Pager
  export let xargs: CV.Chopts

  $: modes = all_modes[xargs.rtype] || {}
  $: descs = all_descs[xargs.rtype] || {}
</script>

<section class="mdesc">Đang áp dụng: {descs[xargs.rmode]}.</section>
<section class="modes chip-list">
  <span class="chip-text u-show-pl">Đổi chế độ:</span>
  {#each Object.entries(modes) as [mode, label]}
    <a
      class="chip-link _active"
      href={pager.gen_url({ rm: xargs.rtype, [xargs.rtype]: mode })}
      data-tip={descs[mode]}
      data-tip-loc="bottom">
      <span>{label}</span>
      {#if xargs.rmode == mode}<SIcon name="check" />{/if}
    </a>
  {/each}
</section>

<style lang="scss">
  .mdesc {
    @include flex-ca($gap: 0.25rem);
    @include fgcolor(mute);
    @include ftsize(sm);
    line-height: 1.25rem;
    margin: 0.25rem 0;
    font-style: italic;
  }

  .modes {
    padding-bottom: 0.75rem;
  }
</style>
