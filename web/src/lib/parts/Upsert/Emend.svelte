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
    <span class="lbl">Bạn đủ quyền hạn để thêm/sửa từ :)</span>
  {:else}
    <span class="lbl _disable">Bạn chưa đủ quyền hạn để thêm/sửa từ :(</span>
  {/if}
</div>

<style lang="scss">
  $height: 1.75rem;

  .edit {
    @include flex($center: horz, $gap: 0.25rem);
    height: $height;
    line-height: $height;
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
