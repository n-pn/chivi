<script>
  import { get_rtime } from '$lib/blocks/RTime.svelte'

  export let info
</script>

{#if info.uname && info.uname != '_'}
  <div class="edit">
    <span class="-text">{info.state} bởi: </span>
    <span class="-user">{info.uname}</span>
    <span class="-text">Q.hạn:</span>
    <span class="-user">{info.privi}</span>
    <span class="-text">Thời gian:</span>
    <span class="-time">{get_rtime(info.mtime)}</span>
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
    @include font-size(1);
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
    @include fgcolor(primary, 8, 0.7);
    font-weight: 500;
  }

  .-user {
    @include truncate(5vw);
  }
</style>
