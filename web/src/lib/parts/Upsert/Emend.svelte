<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  export let term
</script>

{#if term.old_uname && term.old_uname != '_'}
  <div class="edit">
    <span class="-text">{term.old_state} bởi: </span>
    <span class="-user">{term.old_uname}</span>
    <span class="-text">Q.hạn:</span>
    <span class="-user">{term.old_privi}</span>
    <span class="-text">Thời gian:</span>
    <span class="-time">{get_rtime(term.old_mtime)}</span>
  </div>
{:else}
  <div class="hint" />
{/if}

<style lang="scss">
  $height: 1.75rem;

  .edit {
    height: $height;
    line-height: $height;
    text-align: center;

    // padding-top: 1px;
    @include ftsize(xs);
    @include fgcolor(neutral, 6);
  }

  .hint {
    height: $height;
    // height: 0.5rem;
  }

  .-text {
    font-style: italic;
  }

  .-time,
  .-user {
    @include fgcolor(primary, 8);
    font-weight: 500;
  }

  .-user {
    @include clamp(5vw);
  }
</style>
