<script context="module" lang="ts">
  type Mode = Record<string, Record<string, string>>

  const all_descs: Mode = {
    qt: {
      qt_v1: 'Dịch thô bằng máy dịch phiên bản cũ',
      bd_zv: 'Dịch thô bằng công cụ Baidu Fanyi',
      ms_zv: 'Dịch thô bằng công cụ Bing Translator',
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
      bd_zv: 'Dịch bằng Baidu',
      ms_zv: 'Dịch bằng Bing',
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
  export let ropts: CV.Rdopts

  $: modes = all_modes[ropts.rmode] || {}
  $: descs = all_descs[ropts.rmode] || {}

  $: rmode = ropts.rmode == 'qt' ? ropts.qt_rm : ropts.mt_rm
</script>

<section class="mdesc">
  <p>Đang áp dụng: {descs[rmode]}.</p>
  {#if rmode == 'qt_v1'}
    <p class="u-warn">
      Bạn đang đọc kết quả dịch của máy dịch cũ đã ngừng bảo trì, hãy thử các
      chế độ dịch khác nếu thấy chưa đủ tốt.
    </p>
  {:else if rmode == 'bt_zv'}
    <p class="u-warn">
      Bạn đang đọc kết quả dịch thô dùng Bing Translator. Đổi sang các kết quả
      dịch máy nếu thấy còn gặp sạn.
    </p>
  {:else if ropts.rmode == 'mt'}
    <p class="u-warn">
      Bạn đang đọc kết quả dịch máy có sử dụng AI để phân tích ngữ pháp, hãy thử
      đổi sang chế độ khác nếu thấy sai nhiều.
    </p>
  {/if}
</section>
<section class="modes chip-list">
  <span class="chip-text u-show-pl">Đổi chế độ:</span>
  {#each Object.entries(modes) as [_mode, label]}
    <a
      class="chip-link _active"
      href={pager.gen_url({ rm: ropts.rmode, [ropts.rmode]: _mode })}
      data-tip={descs[_mode]}
      data-tip-loc="bottom">
      <span>{label}</span>
      {#if rmode == _mode}<SIcon name="check" />{/if}
    </a>
  {/each}
</section>

<style lang="scss">
  .mdesc {
    @include fgcolor(mute);
    @include ftsize(sm);
    line-height: 1.25rem;
    font-style: italic;
    padding: 0.25rem 0;
    padding-bottom: 0.375rem;

    p {
      margin: 0;
      text-align: center;
    }
  }

  .modes {
    padding-bottom: 0.75rem;
    @include border(--bd-soft, $loc: bottom);
  }
</style>
