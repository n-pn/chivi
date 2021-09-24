<script context="module">
  const types = [
    ['_prev', 'Cơ bản'],
    ['_main', 'Nâng cao'],
    ['_priv', 'Cá nhân'],
  ]
</script>

<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  export let term
  export let p_min
  export let p_max
</script>

<div class="edit">
  <span>Q. hạn tối thiểu:</span>
  <span class="val">{p_min}</span>
  <span class="sep">|</span>

  {#if term.old_uname && term.old_uname != '~'}
    <span class="lbl">{term.old_state} bởi: </span>
    <span class="val user">{term.old_uname}</span>
    <span class="lbl">Thời gian:</span>
    <span class="val">{get_rtime(term.old_mtime)}</span>
  {:else if p_max >= p_min}
    <span class="lbl">Bạn đủ quyền hạn để thêm/sửa từ</span>
  {:else}
    <span class="lbl _disable">Bạn chưa đủ quyền hạn để thêm/sửa từ</span>
  {/if}
</div>

<style lang="scss">
  .edit {
    $height: 1rem;
    @include flex($center: horz, $gap: 0.25rem);
    line-height: $height;
    margin: 0.5rem 0;
    text-align: center;

    // padding-top: 1px;
    @include ftsize(xs);
    @include fgcolor(tert);
  }

  .lbl {
    font-style: italic;
    // prettier-ignore
    &._disable { @include fgcolor(mute); }
  }

  .val {
    font-weight: 500;
  }

  .user {
    @include clamp(5vw);
  }
</style>
