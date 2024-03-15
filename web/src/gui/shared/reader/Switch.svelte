<script context="module" lang="ts">
  type Mode = Record<string, string>

  const all_descs: Mode = {
    c_gpt: 'Dịch bằng công cụ dịch GPT Tiên hiệp',
    bd_zv: 'Dịch thô bằng công cụ Baidu Fanyi',
    ms_zv: 'Dịch thô bằng công cụ Bing Translator',

    mtl_1: 'Dịch với trợ giúp từ công cụ AI với model ELECTRA SMALL',
    mtl_2: 'Dịch với trợ giúp từ công cụ AI với model ELECTRA BASE',
    mtl_3: 'Dịch với trợ giúp từ công cụ AI với model ERNIE GRAM',
    qt_v1: 'Dịch thô bằng máy dịch phiên bản cũ',
  }

  const raw_modes: Mode = {
    c_gpt: 'GPT Tiên hiệp',
    bd_zv: 'Dịch qua Baidu',
    ms_zv: 'Dịch qua Bing',
  }

  const pro_modes: Mode = {
    mtl_1: 'Dịch Chivi 1',
    mtl_2: 'Dịch Chivi 2',
    mtl_3: 'Dịch Chivi 3',
    qt_v1: 'Dịch máy cũ',
  }
</script>

<script lang="ts">
  import type { Pager } from '$lib/pager'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let pager: Pager
  export let ropts: CV.Rdopts

  $: rmode = ropts.rmode == 'qt' ? ropts.qt_rm : ropts.mt_rm
</script>

<header class="u-warn">Lựa chọn chế độ dịch để đạt trải nghiệm tốt nhất:</header>

<section class="modes chip-list">
  <span class="chip-text u-show-pl">Dịch ngoài:</span>
  {#each Object.entries(raw_modes) as [_mode, label]}
    <a
      class="chip-link _active"
      href={pager.gen_url({ rm: ropts.rmode, [ropts.rmode]: _mode })}
      data-tip={all_descs[_mode]}
      data-tip-loc="bottom">
      <span>{label}</span>
      {#if rmode == _mode}<SIcon name="check" />{/if}
    </a>
  {/each}
</section>

<section class="modes chip-list">
  <span class="chip-text u-show-pl">Dịch Chivi:</span>
  {#each Object.entries(pro_modes) as [_mode, label]}
    <a
      class="chip-link _pro _active"
      href={pager.gen_url({ rm: ropts.rmode, [ropts.rmode]: _mode })}
      data-tip={all_descs[_mode]}
      data-tip-loc="bottom">
      <span>{label}</span>
      {#if rmode == _mode}<SIcon name="check" />{/if}
    </a>
  {/each}
</section>

<section class="mdesc"></section>

<style lang="scss">
  .modes {
    padding-bottom: 0.5rem;
    flex-wrap: wrap;
  }

  header {
    @include ftsize(sm);
    line-height: 1.25rem;
    font-style: italic;
    padding-bottom: 0.5rem;
    text-align: center;
    font-weight: 500;
    margin-top: -0.25rem;
  }

  .mdesc {
    @include fgcolor(mute);
    @include ftsize(sm);
    line-height: 1.25rem;
    font-style: italic;
    padding-bottom: 0.5rem;
    text-align: center;

    @include border(--bd-soft, $loc: bottom);
  }
</style>
